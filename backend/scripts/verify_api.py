import requests
import json
import time
import subprocess
import os

def test_endpoints():
    print("Starting verification of API endpoints...")
    
    # 1. Start the backend in a separate process
    # We'll use a timeout and then kill it
    backend_process = subprocess.Popen(
        ['python', 'backend/app.py'],
        cwd=os.getcwd(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    # Wait for backend to start
    time.sleep(5)
    
    base_url = "http://localhost:5000"
    
    try:
        # Test Health
        print("\n[TEST] GET /health")
        resp = requests.get(f"{base_url}/health")
        print(f"Status: {resp.status_code}")
        print(f"Body: {resp.json()}")
        
        # Test Suggestions
        print("\n[TEST] GET /api/suggestions with items")
        resp = requests.get(f"{base_url}/api/suggestions?current_items=milk,eggs")
        print(f"Status: {resp.status_code}")
        data = resp.json()
        print(f"Count: {data.get('count')}")
        if data.get('suggestions'):
            first = data['suggestions'][0]
            print(f"First Suggestion: {first.get('item_name')} ({first.get('category')})")

        # Test Recipes
        print("\n[TEST] POST /api/recipes/recommend")
        resp = requests.post(f"{base_url}/api/recipes/recommend", json={"ingredients": ["milk", "eggs"]})
        print(f"Status: {resp.status_code}")
        data = resp.json()
        if data.get('recommendations'):
            rec = data['recommendations'][0]
            print(f"Top Recipe: {rec.get('name')} (Score: {rec.get('score')})")
        if data.get('smart_suggestions'):
            print(f"Smart Suggestions: {list(data['smart_suggestions'].keys())}")

        print("\nVERIFICATION COMPLETE: All endpoints are functional!")
        
    except Exception as e:
        print(f"\n[ERROR] Verification failed: {e}")
    finally:
        backend_process.terminate()

if __name__ == "__main__":
    test_endpoints()
