from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.config import get_settings, round_iqd, round_usd
from ..core.db import get_db
from ..schemas.settings import SettingsOut, SettingsUpdate
from ..repositories.settings_repo import SettingsRepository
from decimal import Decimal
from datetime import date

router = APIRouter()

@router.get("/health")
def health():
    return {"status": "ok"}

@router.get("/", response_model=SettingsOut)
def get_app_settings(db: Session = Depends(get_db)):
    repo = SettingsRepository(db)
    s_db = repo.get_settings()
    return SettingsOut(
        app_name=s_db.app_name,
        base_currency=s_db.base_currency,
        iqd_step=s_db.iqd_step,
        usd_round="0.01",
    )

@router.put("/update", response_model=SettingsOut)
def update_app_settings(payload: SettingsUpdate, db: Session = Depends(get_db)):
    repo = SettingsRepository(db)
    s_db = repo.update_settings(
        base_currency=payload.base_currency,
        iqd_step=payload.iqd_step,
    )
    return SettingsOut(
        app_name=s_db.app_name,
        base_currency=s_db.base_currency,
        iqd_step=s_db.iqd_step,
        usd_round="0.01",
    )

@router.post("/exchange-rate")
def set_exchange_rate(from_currency: str = "USD", to_currency: str = "IQD", effective: date = date.today(), rate: float = 1300.0, db: Session = Depends(get_db)):
    repo = SettingsRepository(db)
    obj = repo.set_exchange_rate(
        from_currency=from_currency,
        to_currency=to_currency,
        effective=effective,
        rate=Decimal(str(rate)),
    )
    return {
        "id": obj.id,
        "from_currency": obj.from_currency,
        "to_currency": obj.to_currency,
        "effective_date": str(obj.effective_date),
        "rate": float(obj.rate),
    }

@router.get("/exchange-rate/latest")
def get_latest_exchange_rate(from_currency: str = "USD", to_currency: str = "IQD", db: Session = Depends(get_db)):
    repo = SettingsRepository(db)
    obj = repo.get_latest_rate(from_currency=from_currency, to_currency=to_currency)
    if not obj:
        return {"rate": None}
    return {
        "id": obj.id,
        "from_currency": obj.from_currency,
        "to_currency": obj.to_currency,
        "effective_date": str(obj.effective_date),
        "rate": float(obj.rate),
    }

@router.post("/rounding-test")
def rounding_test(amount: float, currency: str = "IQD"):
    if currency.upper() == "IQD":
        return {"rounded": round_iqd(Decimal(str(amount)), get_settings().iqd_step)}
    return {"rounded": float(round_usd(Decimal(str(amount))))}