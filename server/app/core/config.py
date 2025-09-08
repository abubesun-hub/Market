from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings
from decimal import Decimal, ROUND_HALF_UP
from functools import lru_cache


class Settings(BaseSettings):
    app_name: str = "Market API"
    debug: bool = False
    # Database
    database_url: str = "postgresql+psycopg://market:market@localhost:5432/market"

    # Currency and rounding
    base_currency: str = "IQD"  # main currency
    # rounding steps
    iqd_step: int = 250  # round to nearest 250

    class Config:
        env_file = ".env"


class CurrencyRules(BaseModel):
    base_currency: str = Field(default="IQD")
    iqd_step: int = Field(default=250, description="Rounding step for IQD")


@lru_cache

def get_settings() -> Settings:
    return Settings()


def round_iqd(amount: Decimal, step: int = 250) -> int:
    """Round IQD amounts to nearest step (default 250). Returns integer IQD."""
    step_dec = Decimal(step)
    return int((amount / step_dec).to_integral_value(rounding=ROUND_HALF_UP) * step_dec)


def round_usd(amount: Decimal) -> Decimal:
    """Round USD to 0.01 always."""
    return amount.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)