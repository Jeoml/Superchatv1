from groq import Groq
import os

groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def call_groq(messages):
    response = groq_client.chat.completions.create(
        model="llama-3.3-70b-versatile",  # or other Groq model
        messages=messages
    )
    return response.choices[0].message.content
