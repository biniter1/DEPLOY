import re
from fastapi import APIRouter
from app.db import schemas
from app.services.ai_services import TextToSpeechService as service
from app.db.schemas import *

router = APIRouter()

def extract_audio_text(text: str) -> str:
    match = re.search(r"['\"](.*?)['\"]", text)
    if match:
        return match.group(1)
    return text  

@router.post("/")
def text_to_speech(prompt: schemas.TTSClientRequest):
    """
    Chuyển văn bản thành giọng nói
    """
    audio_url = service.text_to_speech(extract_audio_text(prompt.text), prompt.voice, prompt.speed)
    return {"audio_url": audio_url}  