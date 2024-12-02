from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from subprocess import run

app = FastAPI()

class EmailList(BaseModel):
    name: str
    description: str
    owner: str

@app.post("/api/create_list/")
async def create_list(email_list: EmailList):
    try:
        run(["mailman", "create", email_list.name, email_list.owner], check=True)
        return {"status": "success", "message": f"List {email_list.name} created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/lists/")
async def list_lists():
    try:
        result = run(["mailman", "lists"], capture_output=True, text=True, check=True)
        return {"status": "success", "lists": result.stdout.splitlines()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

