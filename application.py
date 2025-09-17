import joblib
import numpy as np
from config.paths_config import MODEL_OUTPUT_PATH
from flask import Flask, render_template, request, Response
from prometheus_client import Counter, generate_latest
import os

app = Flask(__name__)

loaded_model = joblib.load(MODEL_OUTPUT_PATH)

prediction_count = Counter('prediction_count' , "Number of prediction count" )

@app.route('/', methods=['GET','POST'])
def index():
    if request.method == 'POST':
        try:
            lead_time = int(request.form["lead_time"])
            no_of_special_request = int(request.form["no_of_special_request"])
            avg_price_per_room = float(request.form["avg_price_per_room"])
            arrival_month = int(request.form["arrival_month"])
            arrival_date = int(request.form["arrival_date"])
            market_segment_type = int(request.form["market_segment_type"])
            no_of_week_nights = int(request.form["no_of_week_nights"])
            no_of_weekend_nights = int(request.form["no_of_weekend_nights"])
            type_of_meal_plan = int(request.form["type_of_meal_plan"])
            room_type_reserved = int(request.form["room_type_reserved"])

            features = np.array([[lead_time, no_of_special_request, avg_price_per_room,
                                  arrival_month, arrival_date, market_segment_type,
                                  no_of_week_nights, no_of_weekend_nights,
                                  type_of_meal_plan, room_type_reserved]])

            prediction = loaded_model.predict(features)

            # Count successful predictions
            prediction = loaded_model.predict(features)[0]
            prediction_count.inc()

            # prediction_counter.labels(model="hotel_booking_model", status="success").inc()

            return render_template('index.html', prediction=prediction[0])

        except Exception:
            # Count failed predictions
            # prediction_counter.labels(model="hotel_booking_model", status="error").inc()
            return render_template('index.html', prediction="Error occurred")

    return render_template("index.html", prediction=None)

# Expose /metrics endpoint for Prometheus
@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype="text/plain")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
