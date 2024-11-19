require 'httparty'

class ForecastController < ApplicationController

  def index
    city = params[:city]
    country = params[:country]
    days = 10
    response = HTTParty.get("https://api.weatherbit.io/v2.0/forecast/daily", {
      query: {
        city: city,
        country: country,
        days: days,
        key: ENV['WEATHERBIT_API_KEY']
      }
    })

    if response.success?
      data = response.parsed_response
      forecast_data = data['data']

      average_temp = calculate_average_temp(forecast_data)
      seven_day_forecast = forecast_data.first(7).map do |day|
        {
          date: day['datetime'],
          temp: day['temp']
        }
      end

      render json: {
        average_temp: average_temp,
        seven_day_forecast: seven_day_forecast
      }
    else
      render json: { error: 'City not found or API error' }, status: :not_found
    end
  end

  private

  def calculate_average_temp(forecast_data)
    temps = forecast_data.map { |day| day['temp'] }
    temps.sum / temps.size.to_f
  end
end
