import os
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator
from pydantic import BaseModel
from sqlalchemy import Boolean, Column, DateTime, Integer, String, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

DATABASE_URL = (
    f"postgresql+psycopg2://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASSWORD']}"
    f"@{os.environ['POSTGRES_HOST']}:{os.environ.get('POSTGRES_PORT', '5432')}"
    f"/{os.environ['POSTGRES_DB']}"
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    done = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class TaskCreate(BaseModel):
    title: str


class TaskUpdate(BaseModel):
    title: str | None = None
    done: bool | None = None


class TaskOut(BaseModel):
    id: int
    title: str
    done: bool
    created_at: datetime

    class Config:
        from_attributes = True


app = FastAPI(title="tasks-api")
Instrumentator().instrument(app).expose(app)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/tasks", response_model=TaskOut, status_code=201)
def create_task(task: TaskCreate):
    with SessionLocal() as db:
        db_task = Task(title=task.title)
        db.add(db_task)
        db.commit()
        db.refresh(db_task)
        return db_task


@app.get("/tasks", response_model=list[TaskOut])
def list_tasks():
    with SessionLocal() as db:
        return db.query(Task).order_by(Task.id).all()


@app.get("/tasks/{task_id}", response_model=TaskOut)
def get_task(task_id: int):
    with SessionLocal() as db:
        task = db.get(Task, task_id)
        if task is None:
            raise HTTPException(status_code=404, detail="Task not found")
        return task


@app.patch("/tasks/{task_id}", response_model=TaskOut)
def update_task(task_id: int, update: TaskUpdate):
    with SessionLocal() as db:
        task = db.get(Task, task_id)
        if task is None:
            raise HTTPException(status_code=404, detail="Task not found")
        if update.title is not None:
            task.title = update.title
        if update.done is not None:
            task.done = update.done
        db.commit()
        db.refresh(task)
        return task


@app.delete("/tasks/{task_id}", status_code=204)
def delete_task(task_id: int):
    with SessionLocal() as db:
        task = db.get(Task, task_id)
        if task is None:
            raise HTTPException(status_code=404, detail="Task not found")
        db.delete(task)
        db.commit()
