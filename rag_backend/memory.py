from sqlalchemy.orm import Session
from models import Memory

def store_message(db: Session, session_id: str, role: str, content: str):
    msg = Memory(session_id=session_id, role=role, content=content)
    db.add(msg)
    db.commit()

def get_history(db: Session, session_id: str):
    return db.query(Memory).filter_by(session_id=session_id).order_by(Memory.timestamp).all()
