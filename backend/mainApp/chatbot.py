import ollama
from pathlib import Path

def load_knowledge(file_path):
    """Wczytuje wiedzę z pliku tekstowego"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Plik {file_path} nie istnieje!")
        return ""


knowledge = load_knowledge('wiedza_o_fotowoltaice.txt')

system_prompt = f"""
Jesteś ekspertem od energii słonecznej. 
Odpowiadaj na pytania korzystając z tej wiedzy:
{knowledge}
Jeśli nie znasz odpowiedzi, powiedz że nie wiesz.
"""

response = ollama.generate(
    model='mistral',
    prompt="Jak działa fotowoltaika?",
    system=system_prompt,
    options={'temperature': 0.7}
)

print(response['response'])