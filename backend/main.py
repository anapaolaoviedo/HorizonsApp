from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP, func
from sqlalchemy.orm import sessionmaker, declarative_base, Session
from passlib.hash import bcrypt
from pydantic import BaseModel, EmailStr
import os
from dotenv import load_dotenv

# --- Cargar variables de entorno ---
load_dotenv()
PG_HOST = os.getenv("PG_HOST", "localhost")
PG_DATABASE = os.getenv("PG_DATABASE", "horizons")
PG_USER = os.getenv("PG_USER", "postgres")
PG_PASSWORD = os.getenv("PG_PASSWORD", "mysecretpassword")
PG_PORT = os.getenv("PG_PORT", 5432)

DATABASE_URL = f"postgresql+psycopg2://{PG_USER}:{PG_PASSWORD}@{PG_HOST}:{PG_PORT}/{PG_DATABASE}"

# --- Configuración de la Base de Datos ---
engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

# --- Modelos de SQLAlchemy ---
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())

Base.metadata.create_all(bind=engine)

# --- Modelos de Pydantic ---
class SignupRequest(BaseModel):
    username: str
    email: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str

    class Config:
        from_attributes = True # Para Pydantic v2

# --- Configuración de la App ---
app = FastAPI(title="Horizons API", description="Vocational guidance platform API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Dependencia para la sesión de DB ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- Rutas ---
@app.post("/signup", response_model=UserResponse)
def signup(request: SignupRequest, db: Session = Depends(get_db)):
    print(f"🔥 SIGNUP REQUEST: {request.username}, {request.email}")
    
    # Revisar si el usuario ya existe
    existing = db.query(User).filter(
        (User.email == request.email) | (User.username == request.username)
    ).first()
    
    if existing:
        print(f"❌ User already exists: {existing.username}")
        raise HTTPException(
            status_code=400,
            detail="Usuario o correo ya existe"
        )

    # --- INICIO DEL CÓDIGO CORREGIDO ---
    try:
        # Crear nuevo usuario
        user = User(
            username=request.username,
            email=request.email,
            password_hash=bcrypt.hash(request.password)
        )
        
        print(f"📝 Creating user: {user.username}")
        db.add(user)
        db.commit()
        print(f"✅ User committed to DB")
        db.refresh(user)
        print(f"🆔 User ID: {user.id}")
        
        return user # Pydantic convierte el objeto 'user' a la respuesta JSON

    except Exception as e:
        # Si algo falla, deshacemos la transacción para no dejar datos corruptos
        print(f"🚨 ERROR: Ocurrió un error, haciendo rollback. Error: {e}")
        db.rollback()
        # Levantamos un error para notificar al cliente
        raise HTTPException(
            status_code=500,
            detail="Error interno al crear el usuario."
        )
    # --- FIN DEL CÓDIGO CORREGIDO ---

@app.post("/login", response_model=UserResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    """Autentica al usuario y devuelve sus datos"""
    user = db.query(User).filter(User.email == request.email).first()
    
    if not user or not bcrypt.verify(request.password, user.password_hash):
        raise HTTPException(
            status_code=401,
            detail="Credenciales inválidas"
        )
    
    return user

@app.get("/healthz")
def health():
    """Endpoint para health check"""
    return {"status": "ok"}

# --- Endpoints adicionales para pruebas ---
@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Obtener usuario por ID (para pruebas)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)
