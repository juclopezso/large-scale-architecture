#!/bin/bash

echo "========================================="
echo "  ERTMS Skeleton — Service Tests"
echo "========================================="

echo ""
echo "--- Web UIs (open in browser) ---"
echo "Passenger Portal:   http://localhost:8016"
echo "Operator Dashboard: http://localhost:8017"
echo "Driver Interface:   http://localhost:8018"

echo ""
echo "--- Health Checks (via API Gateway :8015) ---"
echo ""

for svc in passengers routes trains position tickets; do
  echo "> GET /$svc/health"
  curl -s http://localhost:8015/$svc/health
  echo ""
done

echo "> GET /authority/health (MAS)"
curl -s http://localhost:8015/authority/health
echo ""

echo ""
echo "--- Get Records (passengers) ---"
echo "> GET /passengers/records"
curl -s http://localhost:8015/passengers/records
echo ""

echo ""
echo "--- Create Record (passengers) ---"
echo "> POST /passengers/records"
curl -s -X POST http://localhost:8015/passengers/records \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe"}'
echo ""

echo ""
echo "--- Verify Record Created ---"
echo "> GET /passengers/records"
curl -s http://localhost:8015/passengers/records
echo ""

echo ""
echo "--- Movement Authority Request ---"
echo "> POST /authority"
curl -s -X POST http://localhost:8015/authority \
  -H "Content-Type: application/json" \
  -d '{"train_id": "T-001", "corridor": "CORRIDOR-A"}'
echo ""

echo ""
echo "--- Direct Microservice Access ---"
echo "> passengers_ms  :8009/health"
curl -s http://localhost:8009/health
echo ""
echo "> routes_ms      :8010/health"
curl -s http://localhost:8010/health
echo ""
echo "> trains_ms      :8011/health"
curl -s http://localhost:8011/health
echo ""
echo "> position_time_ms :8012/health"
curl -s http://localhost:8012/health
echo ""
echo "> tickets_ms     :8013/health"
curl -s http://localhost:8013/health
echo ""
echo "> mas            :8014/health"
curl -s http://localhost:8014/health
echo ""

echo ""
echo "--- Physical Tier Logs ---"
echo "> onboard_unit"
docker logs skeleton-onboard_unit-1 2>&1 | tail -3
echo "> train_sensor"
docker logs skeleton-train_sensor-1 2>&1 | tail -3
echo "> brake_actuator"
docker logs skeleton-brake_actuator-1 2>&1 | tail -3
echo "> balise"
docker logs skeleton-balise-1 2>&1 | tail -3

echo ""
echo "========================================="
echo "  Tests complete"
echo "========================================="
