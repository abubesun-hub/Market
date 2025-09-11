from sqlalchemy import String, Integer, Date, Numeric, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column
from ..core.db import Base


class AppSettings(Base):
    __tablename__ = "app_settings"
    id: Mapped[int] = mapped_column(primary_key=True)
    app_name: Mapped[str] = mapped_column(String(100), default="Market API")
    base_currency: Mapped[str] = mapped_column(String(3), default="IQD")
    iqd_step: Mapped[int] = mapped_column(Integer, default=250)


class CurrencyRate(Base):
    __tablename__ = "currency_rates"
    id: Mapped[int] = mapped_column(primary_key=True)
    # e.g., USD->IQD stored as rate (how many IQD per 1 USD)
    from_currency: Mapped[str] = mapped_column(String(3))
    to_currency: Mapped[str] = mapped_column(String(3))
    effective_date: Mapped[Date] = mapped_column(Date)
    rate: Mapped[Numeric] = mapped_column(Numeric(18, 6))

    __table_args__ = (
        UniqueConstraint("from_currency", "to_currency", "effective_date", name="uq_currency_rate_date"),
    )