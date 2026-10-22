.PHONY: install test lint run eval eval-fast docker tf-plan

install:
	pip install -e ".[dev]"

test:
	LLM_PROVIDER=fake pytest -q

lint:
	ruff check app evals tests

run:
	ENV=local uvicorn app.server:app --reload --port 8080

# Full eval: real agent + deterministic checks + LLM judge, scores pushed to Langfuse. Gate exits 1 on regression.
eval:
	python -m evals.run_evals --sync-dataset

eval-fast:
	python -m evals.run_evals --no-judge --tags safety

docker:
	docker build -t coach-agent:dev .

tf-plan:
	cd infra/terraform && terraform init -backend-config=envs/$(ENV).backend.hcl && terraform plan -var-file=envs/$(ENV).tfvars
