from fastapi import APIRouter
from .settings import router as settings_router
from .organization import router as organization_router

router = APIRouter()

router.include_router(settings_router, prefix="/settings", tags=["settings"])
router.include_router(organization_router, prefix="/org", tags=["organization"])