
# 🌌 Horizons App — Vocational Guidance Platform

Horizons es una plataforma de orientación vocacional de nueva generación que combina **IA conversacional, simulaciones y juegos** para ayudar a estudiantes a descubrir su camino profesional.  

El proyecto está construido como un ecosistema de **microservicios en Python (FastAPI)** y un **frontend nativo en SwiftUI** para iOS.

---

## 🚀 Tech Stack

- **Frontend:** SwiftUI (dashboards, juegos, simulaciones, chat)
- **Backend APIs:** FastAPI (Python)
- **Database:** PostgreSQL (persistencia a largo plazo) + Redis (memoria de sesión a corto plazo)
- **AI Core:** BRAIN (agente modular como microservicio)

---

## 1. Horizons API (User Platform)

- Implementado en **FastAPI** (puerto `8000`).
- Funcionalidades:
  - Registro e inicio de sesión.
  - Gestión de perfiles de usuario.
  - Persistencia en **PostgreSQL**.
- Objetivo: separar la **identidad y datos de usuario** del sistema de razonamiento de la IA.
- Consumido desde SwiftUI para:
  - Crear cuentas.
  - Validar login.
  - Obtener datos del perfil.

---

## 2. BRAIN API (AI Vocational Assistant)

- Microservicio independiente en **FastAPI** (puerto `8010`).
- Expone un endpoint `/webhook` para recibir mensajes desde SwiftUI.
- Diseñado como un **agente basado en modelos** (model-based agent):

### 🧠 Arquitectura del agente
- **Tuple Agent:** (States, Actions, Transition, Policy, Memory)
- **NLP Pipeline:** extracción de intenciones y entidades (OpenAI + regex fallback).
- **Rule Engine:** reglas de orientación vocacional (ej. detectar intereses → sugerir carreras).
- **Decision Engine:** orquesta reglas, memoria y políticas de fallback.
- **Policy Module:** maneja casos desconocidos o respuestas seguras.
- **Memory Manager:**
  - **Redis:** estado de conversación en tiempo real.
  - **PostgreSQL:** logs históricos y actualización de perfiles estudiantiles.

📌 **Pipeline de decisión:**

`SwiftUI → FastAPI /webhook → NLP Pipeline → Decision Engine → Respuesta → SwiftUI Chat`

---

## 3. SwiftUI Integration

- **ProfileView.swift:** dashboard principal con navegación a juegos, recursos y chat.
- **BrainAPI.swift:** capa de red que envía mensajes al BRAIN API.
- **ChatVM.swift:** ViewModel (MVVM) que mantiene el estado de la conversación y procesa respuestas.
- **ChatScreen.swift:** interfaz de chat estilo burbujas.

🔗 El flujo de navegación:  
Dashboard → Botón "Chat Vocacional" → se abre **ChatScreen** conectado al **ChatVM**.

---

## 4. Conceptual Flow

1. Usuario inicia sesión en **Horizons API (8000)** → datos guardados en Postgres.  
2. En SwiftUI abre “Chat Vocacional”.  
3. El mensaje viaja a **BRAIN API (8010)** vía `/webhook`.  
4. El agente procesa:  
   - **Percepción:** NLP → intentos + entidades.  
   - **Razonamiento:** reglas + política.  
   - **Memoria:** guarda contexto en Redis + Postgres.  
5. BRAIN responde con guía vocacional personalizada.  
6. SwiftUI renderiza la respuesta en burbujas de chat.  

---

## 5. Why It’s Unique ✨

- Más que un chatbot → es una **arquitectura multi-agente inspirada en teoría de agentes**:
  - NLP + reglas + memoria + política de fallback.
- Separación clara de **Horizons API** (datos de usuario) y **BRAIN AI** (razonamiento).
- Persistencia real: cada turno de chat se guarda en **Postgres + Redis**.
- SwiftUI muestra que se puede conectar un **microservicio de IA en Python ↔ app nativa iOS**.
- La app no solo conversa: también ofrece **juegos y simulaciones** que forman parte de la orientación vocacional.

---

## ✨ En resumen

Horizons es una plataforma de orientación vocacional que une:

- **Horizons API** → identidad y datos seguros de usuario.  
- **BRAIN AI Microservice** → motor cognitivo (percepción, razonamiento, memoria, política).  
- **SwiftUI App** → interfaz moderna con dashboard, juegos y chat inteligente.  

🔮 Una propuesta innovadora para ayudar a estudiantes a descubrir y construir su futuro profesional.
