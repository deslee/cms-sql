FROM golang:1.11.4 AS job-processor-builder
WORKDIR /src
COPY ./go.mod ./go.sum ./
RUN go mod download
COPY ./ ./
RUN CGO_ENABLED=1 go build -o cms-jobs assetJob.go

FROM golang:1.11.4 AS cms-jobs
WORKDIR /app
EXPOSE 80
ENV PORT=80
COPY --from=job-processor-builder /src /app
ENTRYPOINT ["/app/cms-jobs"]