# Builder
FROM golang:1.24.5-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
COPY . .
RUN go mod tidy
RUN go build -o /app/main ./app

# Imagen final
FROM alpine:latest

WORKDIR /app

# Se instala poppler-utils para poder usar pdftotext.
# También se instala chronium para podder ussar crodp.
# Ambos sirven para la validación de la constancia de alumno regular.
RUN apk add --no-cache poppler-utils
RUN apk add --no-cache chromium nss freetype harfbuzz ttf-freefont

# Creación de un usuario y grupo no root.
RUN addgroup -S uki && adduser -S uki -G uki

COPY --from=builder /app/main .

COPY static ./static
COPY template ./template

# Se brinda al usuario no root permisos para ejecutar la app.
RUN chown -R uki:uki /app

EXPOSE 8080

# Se cambia al usuario no root.
USER uki

CMD ["./main"]

# Puede verse el contenido en el directorio /app mediante los siguientes comandos:
# docker run -it --rm uki sh
# ls -R