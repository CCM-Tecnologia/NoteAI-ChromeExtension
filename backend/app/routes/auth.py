from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..dependencies import get_current_active_user
from .. import auth, models, schemas

router = APIRouter(prefix="/auth", tags=["authentication"])

@router.post("/register", response_model=schemas.User)
async def register_user(
    user: schemas.UserCreate,
    db: Session = Depends(get_db)
):
    """Register a new user"""
    try:
        db_user = auth.create_user(db=db, user=user)
        return db_user
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating user: {str(e)}"
        )

@router.post("/login", response_model=schemas.Token)
async def login_user(
    user_credentials: schemas.UserLogin,
    db: Session = Depends(get_db)
):
    """Login user and return access token"""
    user = auth.authenticate_user(
        db, user_credentials.email, user_credentials.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer"
    }

@router.get("/me", response_model=schemas.User)
async def read_users_me(
    current_user: models.User = Depends(get_current_active_user)
):
    """Get current user information"""
    # Add has_openai_key field
    user_dict = {
        "id": current_user.id,
        "email": current_user.email,
        "name": current_user.name,
        "is_active": current_user.is_active,
        "has_openai_key": bool(current_user.openai_api_key),
        "created_at": current_user.created_at,
        "updated_at": current_user.updated_at
    }
    return user_dict

@router.patch("/me", response_model=schemas.User)
async def update_user_me(
    user_update: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update current user information"""
    updated_user = auth.update_user(db, current_user.id, user_update)
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Return user info with has_openai_key field
    user_dict = {
        "id": updated_user.id,
        "email": updated_user.email,
        "name": updated_user.name,
        "is_active": updated_user.is_active,
        "has_openai_key": bool(updated_user.openai_api_key),
        "created_at": updated_user.created_at,
        "updated_at": updated_user.updated_at
    }
    return user_dict

@router.get("/users", response_model=List[schemas.User])
async def list_users(
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """List all users (for admin purposes)"""
    # In a real application, you might want to restrict this to admin users only
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users