const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type ChatMessage = { role: "user" | "assistant"; content: string };

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
  if (!request.headers.get("Authorization")) return json({ error: "Unauthorized" }, 401);

  const apiKey = Deno.env.get("GROQ_API_KEY");
  if (!apiKey) return json({ error: "Insights service is not configured" }, 503);

  try {
    const body = await request.json();
    const prompt = typeof body.prompt === "string" ? body.prompt.trim() : "";
    const mode = ["home", "daily", "chat"].includes(body.mode) ? body.mode : "chat";
    if (!prompt || prompt.length > 1000) return json({ error: "Invalid prompt" }, 400);

    const activities = Array.isArray(body.activities) ? body.activities.slice(0, 100) : [];
    const usage = Array.isArray(body.usage) ? body.usage.slice(0, 20) : [];
    const history: ChatMessage[] = Array.isArray(body.history)
      ? body.history
          .filter((item: ChatMessage) =>
            ["user", "assistant"].includes(item?.role) &&
            typeof item?.content === "string" &&
            item.content.length <= 2000
          )
          .slice(-8)
      : [];

    const system = [
      "You are ActiBind's activity insights assistant.",
      "Use only the supplied schedule and device-usage context; never invent statistics.",
      "If data is insufficient, say so briefly and still offer a practical suggestion.",
      "Do not provide medical diagnoses. Be concise, supportive, and specific.",
      mode === "home" ? "Return at most two short sentences." : "Return at most 120 words.",
    ].join(" ");
    const context = JSON.stringify({
      local_time: body.local_time,
      timezone: body.timezone,
      recent_activities: activities,
      device_usage_today: usage,
    });

    const groqResponse = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: Deno.env.get("GROQ_MODEL") ?? "llama-3.1-8b-instant",
        temperature: 0.35,
        max_completion_tokens: mode === "home" ? 100 : 240,
        messages: [
          { role: "system", content: system },
          { role: "system", content: `User context: ${context}` },
          ...history,
          { role: "user", content: prompt },
        ],
      }),
    });

    if (!groqResponse.ok) {
      const errorText = await groqResponse.text();
      console.error("Groq request failed", groqResponse.status, errorText.slice(0, 300));
      return json({ error: "AI provider request failed" }, 502);
    }
    const result = await groqResponse.json();
    const insight = result?.choices?.[0]?.message?.content;
    if (typeof insight !== "string" || !insight.trim()) {
      return json({ error: "AI provider returned no insight" }, 502);
    }
    return json({ insight: insight.trim() });
  } catch (error) {
    console.error("Insight function error", String(error));
    return json({ error: "Unable to generate insight" }, 500);
  }
});
