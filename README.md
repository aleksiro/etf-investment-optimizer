# etf-investment-optimizer
Repository that includes code to run ETF investment buying optimizer to be run on GCP

## Contents
- [ETL Documentation](./etl/readme.md)
- [DB Documentation](./db/readme.md)
- [Reporting Documentation](reporting/readme.md)

## Project description
Stock Market timing especially on single stocks in general is doomed to failure. One of the most popular investment methods for consumers is passive monthly investing with fixed amount of money on fixed day of the month. One of the main reasons this has become popular is that financial services companies (such as Nordnet) provide cost efficient ways to automate monthly investing to financial products like ETFs.

This project focuses on creating a linear regression calculation for set of predefined ETFs (EUNL, IUSN, IS3N) with the goal to optimize the amount of investment per month and ticker compared to current price vs. market trend. Briefly, the core idea is to buy bigger amount of stocks when the current price is lower than the market trend, and vice versa buy smaller amount of stock when the current price is higher than the market trend.

**Main questions this project aims to answer are following:** 
- Is it possible to get higher ROI by changing the amount of stocks bought depending on the market trend compared to current price?
- How to calculate moving linear regression (fitting trend line) in SQL?
- How to visualize these results to understand current market trend?
- By backtesting this hypothesis to available stock data (investing varying amount of stocks vs. investing fixed amount of stocks), what is the difference in ROI?

On top of the questions above, this project was a learning journey as my first Google Cloud Platform project with previous experience in Azure and AWS. Project also includes calculations to get the required input values for Nordnet's ETF monthly investment tool.

## Architecture
TODO

## Data sources
- Nordnet ticker data - Fetched on [single ETF's Nordnet page](https://www.nordnet.fi/markkinakatsaus/etf-listat/16309430-i-shares-core-msci) at "Kurssihistoria" -> "Lataa historiallinen data" button. Fetches last 5 years of daily close prices and turnover. This data is monthly manually downloaded from Nordnet site and moved to GCP Cloud Storage.
- Yahoo ticker data - One time fetched historical close price and turnover data set from [Yahoo finance](https://finance.yahoo.com/quote/EUNL.DE/). Includes data from as far as these financial instruments have existed.
- Manually inserted reference data - Includes dimensional data for ETFs (name, type, cost, etc...) and calculation parameters used for specific user. This are added manually with insert statements on db initialization. 

## How to get started
Currently project doesn't yet have cloud infrastructure templates and requires manually creating resources on GCP console and utilizing code found on this repository.

## Limitations and incomplete parts:
- Architecture diagram
- How to get started done correctly
- Backtesting code
- Reporting / visualizations
- Cloud infrastructure templates






[![Sponsored](https://img.shields.io/badge/chilicorn-sponsored-brightgreen.svg?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAA4AAAAPCAMAAADjyg5GAAABqlBMVEUAAAAzmTM3pEn%2FSTGhVSY4ZD43STdOXk5lSGAyhz41iz8xkz2HUCWFFhTFFRUzZDvbIB00Zzoyfj9zlHY0ZzmMfY0ydT0zjj92l3qjeR3dNSkoZp4ykEAzjT8ylUBlgj0yiT0ymECkwKjWqAyjuqcghpUykD%2BUQCKoQyAHb%2BgylkAyl0EynkEzmkA0mUA3mj86oUg7oUo8n0k%2FS%2Bw%2Fo0xBnE5BpU9Br0ZKo1ZLmFZOjEhesGljuzllqW50tH14aS14qm17mX9%2Bx4GAgUCEx02JySqOvpSXvI%2BYvp2orqmpzeGrQh%2Bsr6yssa2ttK6v0bKxMBy01bm4zLu5yry7yb29x77BzMPCxsLEzMXFxsXGx8fI3PLJ08vKysrKy8rL2s3MzczOH8LR0dHW19bX19fZ2dna2trc3Nzd3d3d3t3f39%2FgtZTg4ODi4uLj4%2BPlGxLl5eXm5ubnRzPn5%2Bfo6Ojp6enqfmzq6urr6%2Bvt7e3t7u3uDwvugwbu7u7v6Obv8fDz8%2FP09PT2igP29vb4%2BPj6y376%2Bu%2F7%2Bfv9%2Ff39%2Fv3%2BkAH%2FAwf%2FtwD%2F9wCyh1KfAAAAKXRSTlMABQ4VGykqLjVCTVNgdXuHj5Kaq62vt77ExNPX2%2Bju8vX6%2Bvr7%2FP7%2B%2FiiUMfUAAADTSURBVAjXBcFRTsIwHAfgX%2FtvOyjdYDUsRkFjTIwkPvjiOTyX9%2FAIJt7BF570BopEdHOOstHS%2BX0s439RGwnfuB5gSFOZAgDqjQOBivtGkCc7j%2B2e8XNzefWSu%2BsZUD1QfoTq0y6mZsUSvIkRoGYnHu6Yc63pDCjiSNE2kYLdCUAWVmK4zsxzO%2BQQFxNs5b479NHXopkbWX9U3PAwWAVSY%2FpZf1udQ7rfUpQ1CzurDPpwo16Ff2cMWjuFHX9qCV0Y0Ok4Jvh63IABUNnktl%2B6sgP%2BARIxSrT%2FMhLlAAAAAElFTkSuQmCC)](http://spiceprogram.org/oss-sponsorship)
