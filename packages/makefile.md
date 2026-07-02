
---

## 3. Makefile для генерации DTOs

Создаю `packages/shared/Makefile`:

```makefile
.PHONY: generate-dto generate-go generate-flutter validate docs clean help

# Default target
help:
	@echo "MetaCart API - Available commands:"
	@echo ""
	@echo "  make generate-dto      Generate all DTOs (Go + Flutter)"
	@echo "  make generate-go       Generate Go DTOs only"
	@echo "  make generate-flutter  Generate Flutter DTOs only"
	@echo "  make validate          Validate OpenAPI schema"
	@echo "  make docs              Preview API documentation"
	@echo "  make clean             Remove generated files"
	@echo ""

# Generate all DTOs
generate-dto: generate-go generate-flutter
	@echo "✅ All DTOs generated successfully"

# Generate Go DTOs
generate-go:
	@echo "🔧 Generating Go DTOs..."
	@mkdir -p ../../apps/api/internal/dto
	@oapi-codegen -config openapi/go-config.yaml openapi/metacart-api.yaml > ../../apps/api/internal/dto/generated.go
	@echo "✅ Go DTOs generated: apps/api/internal/dto/generated.go"

# Generate Flutter DTOs
generate-flutter:
	@echo "🔧 Generating Flutter DTOs..."
	@mkdir -p ../../apps/mobile/lib/core/api/dto
	@openapi_generator -i openapi/metacart-api.yaml -o ../../apps/mobile/lib/core/api/dto -g dart
	@echo "✅ Flutter DTOs generated: apps/mobile/lib/core/api/dto/"

# Validate OpenAPI schema
validate:
	@echo "🔍 Validating OpenAPI schema..."
	@npx @redocly/cli lint openapi/metacart-api.yaml
	@echo "✅ Schema is valid"

# Preview API documentation
docs:
	@echo "📖 Starting API documentation preview..."
	@npx @redocly/cli preview-docs openapi/metacart-api.yaml

# Clean generated files
clean:
	@echo "🧹 Cleaning generated files..."
	@rm -f ../../apps/api/internal/dto/generated.go
	@rm -rf ../../apps/mobile/lib/core/api/dto
	@echo "✅ Cleaned"

# Install dependencies (run once)
install-deps:
	@echo "📦 Installing dependencies..."
	@go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@latest
	@npm install -g @redocly/cli
	@pip install openapi-generator-cli
	@echo "✅ Dependencies installed"