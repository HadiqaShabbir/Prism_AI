const express = require('express');
const cors = require('cors');
require('dotenv').config();

const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();

app.use(cors());
app.use(express.json());

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.error('GEMINI_API_KEY is missing from .env');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(apiKey);

app.post('/parse-request', async (req, res) => {
  try {
    const { userInput, userCity } = req.body;

    if (!userInput || !userCity) {
      return res.status(400).json({
        error: 'userInput and userCity are required',
      });
    }

    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
    });

    const prompt = `
You are an AI service request parser for Pakistan's informal economy app called PRISM AI.

User submitted this request: "${userInput}"
User registered city: "${userCity}"

Return ONLY valid JSON, no extra text, no markdown, no backticks:

{
  "service": "detected service",
  "city": "detected city",
  "location": "specific area mentioned",
  "time": "when they need it",
  "urgency": "Low or Medium or High",
  "budget": "Low or Medium or High",
  "confidence": 85,
  "language": "English or Roman Urdu or Mixed",
  "reasoning": "brief explanation"
}

Rules:
- service: AC Repair, Electrician, Plumbing, Beautician, Tutor, Cleaning, Mechanic, Shifting, General Service
- city: Karachi, Lahore, Islamabad, Rawalpindi, Peshawar, Quetta, Faisalabad, Multan — if not found use "$userCity"
- urgency High if: aaj/today/abhi/jaldi/urgent/tonight
- urgency Medium if: kal/tomorrow
- urgency Low if: weekend/flexible
- budget Low if: sasta/cheap/budget/kam paise
- budget High if: best/premium/quality
- budget: if not mentioned, always return "Medium" as default
- confidence 0-99 based on clarity
`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();

    const clean = text
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .trim();

    const parsed = JSON.parse(clean);

    if (!parsed.budget || parsed.budget.toString().trim() === '') {
      parsed.budget = 'Medium';
    }

    res.json(parsed);
  } catch (error) {
    console.error('Gemini error:', error);

    res.status(500).json({
      error: 'Failed to process the request',
    });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`PRISM AI backend running on http://localhost:${PORT}`);
});