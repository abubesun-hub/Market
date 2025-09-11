from sqlalchemy.orm import Session
from sqlalchemy import select
from ..models.settings import AppSettings, CurrencyRate
from datetime import date
from decimal import Decimal


class SettingsRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_settings(self) -> AppSettings:
        stmt = select(AppSettings).limit(1)
        obj = self.db.execute(stmt).scalars().first()
        if not obj:
            obj = AppSettings()
            self.db.add(obj)
            self.db.commit()
            self.db.refresh(obj)
        return obj

    def update_settings(self, *, base_currency: str | None, iqd_step: int | None) -> AppSettings:
        s = self.get_settings()
        if base_currency:
            s.base_currency = base_currency
        if iqd_step:
            s.iqd_step = iqd_step
        self.db.commit()
        self.db.refresh(s)
        return s

    def set_exchange_rate(self, *, from_currency: str, to_currency: str, effective: date, rate: Decimal) -> CurrencyRate:
        # upsert simplistic: try get existing by unique key
        stmt = select(CurrencyRate).where(
            CurrencyRate.from_currency == from_currency,
            CurrencyRate.to_currency == to_currency,
            CurrencyRate.effective_date == effective,
        )
        obj = self.db.execute(stmt).scalars().first()
        if obj:
            obj.rate = rate
        else:
            obj = CurrencyRate(
                from_currency=from_currency,
                to_currency=to_currency,
                effective_date=effective,
                rate=rate,
            )
            self.db.add(obj)
        self.db.commit()
        self.db.refresh(obj)
        return obj

    def get_latest_rate(self, *, from_currency: str, to_currency: str) -> CurrencyRate | None:
        stmt = (
            select(CurrencyRate)
            .where(
                CurrencyRate.from_currency == from_currency,
                CurrencyRate.to_currency == to_currency,
            )
            .order_by(CurrencyRate.effective_date.desc(), CurrencyRate.id.desc())
            .limit(1)
        )
        return self.db.execute(stmt).scalars().first()