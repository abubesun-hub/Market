# Market Server (FastAPI)

## Quick start

1. Create and activate Python 3.11+ environment
2. Install requirements

```powershell
python -m venv .venv
. .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

3. Configure environment (.env)

```
DATABASE_URL=postgresql+psycopg://market:market@localhost:5432/market
APP_NAME=Market API
DEBUG=false
BASE_CURRENCY=IQD
IQD_STEP=250
```

4. Initialize database (Alembic migrations)

```powershell
$env:DATABASE_URL="postgresql+psycopg://market:market@localhost:5432/market"
alembic upgrade head
```

5. Run development server

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

6. Test endpoints
- http://localhost:8000/ -> root
- http://localhost:8000/settings/health -> health
- http://localhost:8000/settings -> get settings (from DB)
- PUT http://localhost:8000/settings/update { base_currency, iqd_step }
- POST http://localhost:8000/settings/exchange-rate?rate=1300&effective=2025-09-09
- GET http://localhost:8000/settings/exchange-rate/latest
- POST http://localhost:8000/settings/rounding-test?amount=1234.56&currency=IQD
- GET http://localhost:8000/org/branches
- POST http://localhost:8000/org/branches { code, name, address }
- GET http://localhost:8000/org/warehouses?branch_id=1
- POST http://localhost:8000/org/warehouses { code, name, branch_id }

## Notes
- Settings now persist in PostgreSQL via SQLAlchemy + Alembic.
- IQD rounding step default is 250, USD fixed to 0.01.
- Branches/Warehouses added with simple CRUD (list/create).