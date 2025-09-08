# Market Server (FastAPI)

## Quick start

1. Create and activate Python 3.11+ environment
2. Install requirements

```powershell
python -m venv .venv
. .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

3. Run development server

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

4. Test endpoints
- http://localhost:8000/ -> root
- http://localhost:8000/settings/health -> health
- http://localhost:8000/settings -> get settings
- POST http://localhost:8000/settings/rounding-test?amount=1234.56&currency=IQD

## Notes
- Settings use in-memory defaults for now. Persisting to PostgreSQL will be added next.
- IQD rounding step default is 250, USD fixed to 0.01.