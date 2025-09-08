from pydantic import BaseModel, Field

class SettingsOut(BaseModel):
    app_name: str
    base_currency: str = Field(default="IQD")
    iqd_step: int = Field(default=250)
    usd_round: str = Field(default="0.01")

class SettingsUpdate(BaseModel):
    # For now allow manual update of base currency and iqd_step and exchange rate
    base_currency: str | None = None
    iqd_step: int | None = None
    exchange_rate_usd_to_iqd: float | None = Field(default=None, description="Manual exchange rate USD->IQD")