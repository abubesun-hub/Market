from fastapi import APIRouter
from ..core.config import get_settings, round_iqd, round_usd
from ..schemas.settings import SettingsOut, SettingsUpdate
from decimal import Decimal

router = APIRouter()

@router.get("/health")
def health():
    return {"status": "ok"}

@router.get("/", response_model=SettingsOut)
def get_app_settings():
    s = get_settings()
    return SettingsOut(
        app_name=s.app_name,
        base_currency=s.base_currency,
        iqd_step=s.iqd_step,
        usd_round="0.01",
    )

@router.post("/rounding-test")
def rounding_test(amount: float, currency: str = "IQD"):
    if currency.upper() == "IQD":
        return {"rounded": round_iqd(Decimal(str(amount)), get_settings().iqd_step)}
    return {"rounded": float(round_usd(Decimal(str(amount))))}

@router.put("/update", response_model=SettingsOut)
def update_app_settings(payload: SettingsUpdate):
    # Note: For bootstrap we update only in-memory settings.
    # Later this should persist into DB.
    s = get_settings()
    if payload.base_currency:
        s.base_currency = payload.base_currency
    if payload.iqd_step:
        s.iqd_step = payload.iqd_step
    # exchange rate will be stored later

    return SettingsOut(
        app_name=s.app_name,
        base_currency=s.base_currency,
        iqd_step=s.iqd_step,
        usd_round="0.01",
    )