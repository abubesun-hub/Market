from fastapi import FastAPI
from .api.routes import router as api_router

app = FastAPI(title="Market API")

@app.get("/")
def root():
    return {"name": "Market API"}

app.include_router(api_router)