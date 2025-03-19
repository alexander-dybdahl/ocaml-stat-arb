import yfinance as yf

if __name__ == '__main__':
    # Fetch historical data for Apple (AAPL) from Yahoo Finance
    data = yf.download('AAPL', start='2020-01-01', end='2021-01-01')

    # Save the data to a CSV file
    data.to_csv('apple_stock_data.csv')