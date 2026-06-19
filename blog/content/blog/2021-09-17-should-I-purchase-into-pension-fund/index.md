+++
title = "Should I purchase into my pension fund?"
[taxonomies]
tags = [ "retirement", "investment", "pension", "Switzerland" ]
+++

You've probably heard from people that it makes sense to purchase into your pension fund, as you can save taxes by doing so. In this post I will take a critical look at that suggestion.

## Why can I purchase into my pension fund?

The pension fund calculates how much you could have saved until now based on your insured salary, and your age. If the amount that is actually saved in the pension fund is lower than that number, you can deposit up to the difference to "fill up" your pension savings. Usually a difference like this occurs when your insured salary increased, or because you weren't working for a period of time. [^futurepost]

## Why would I want to purchase into my pension fund?

To save taxes. The amount purchased into the pension fund is wholly deductable from your income, so it can result in a direct saving of taxes.

## Sounds clear cut, why shouldn't I just do it?

Basically _opportunity cost_. By depositing the money into the pension fund, on the one hand you have a tax saving, but on the other hand your money is now invested in the pension fund. If you thought that you could make a better return on your investment than the pension fund can, it might be smarter to forgo the tax savings.

## Before we get into it, is there a short answer?

Kind of. Let's start with the simplest case: if you're not planning on investing your money (i.e. you'll leave it as cash in your bank account), it'll do better in your pension fund, so you _should_ purchase into your pension fund. If you're planning on investing your money in the stock market, and you're more than 20 years away from retirement, it's almost certainly better _not to_ purchase into your pension fund.

## The factors at play

Let's build a model of how this works, so that we can analyse what makes sense when. In principle we are going to compare two scenarios. In scenario 1, we deposit a fixed amount into the pension fund, have some tax savings, and plan on investing those savings into the stock market. In scenario 2, we invest the fixed amount in the stock market directly (and have no tax savings).

Let's quantify the factors involved:

- __Purchase amount__ `P`: The exact amount is not relevant, as we shall see, but it helps to have a number to work with.
- __Marginal tax rate__ (_Grenzsteuersatz_) `T`: The tax percentage which would be applied to the purchase amount. This is dependent on your annual income `I`.
- __Pension fund return__ `r_p`: The annual return (interest rate) that your pension fund will apply to your savings. By law this must be a minimum of 1%, but some pension funds have a greater return [^pkvergleich]. My pension fund, ASGA, had an interest rate of 2.75% for 2020.
- __Expected investment return__ `r_i`: The annual return that you expect to be able to achieve through investment in the stock market. How you get to this number is probably dependent on your personality and risk profile. The average (inflation-adjusted) return of the S&P500 from 1926 to 2018 was about 7% [^investopediasnp], for the SMI this figure is 5.8% [^moneyparksmi].

### Marginal tax rate

The _actual_ marginal tax rate which will apply to you is dependent on a number of factors, most important of which being the canton and municipality (_Gemeinde_) that you live in, but also: whether you're married or not, whether you have children or not, whether you are a member of the church.

For the rest of this discussion, I present the following table [^MTRT], which maps income to marginal tax percentage for the city of Zürich:

| Income (CHF) | Tax amount (CHF) | Tax percentage | Marginal tax rate |
|-------------:|-----------------:|---------------:|------------------:|
| 50'000       | 4'595.55         | 9.19%	   | -                 |
| 60'000       | 6'212.95         | 10.35%         | 16.17%            |
| 70'000       | 7'964.95         | 11.38%         | 17.52%            |
| 80'000       | 9'870.25         | 12.34%         | 19.05%            |
| 100'000      | 13'812.25	  | 13.81%         | 19.71%            |
| 125'000      | 19'164.60        | 15.33%         | 21.41%            |
| 150'000      | 24'911.15        | 16.61%         | 22.99%            |
| 200'000      | 37'201.45        | 18.60%         | 24.58%            |
| 250'000      | 50'339.25        | 20.14%         | 26.28%            |
| 300'000      | 64'469.15        | 21.49%         | 28.26%            |
| 500'000      | 121'404.75       | 24.28%         | 28.47%            |
| 1'000'000    | 263'743.80       | 26.37%         | 28.47%            |

This basically says that earnings above 100'000 CHF will be taxed at 19.71%. If you would reduce your income from 120kCHF to 110kCHF by depositing into your pension fund, you would have a tax savings of 10kCHF * 19.71% = 1'971 CHF.

### An example

Let's run through an example for each scenario after one year and after 10 years. We will use the following values:

`P =  10'000 CHF`

`I = 120'000 CHF`

`T = ~20%`

`r_p = 2.75%`

`r_i = 6%`

#### Scenario 1 for one year

We deposit 10'000 CHF into the pension fund. As a result we have a tax savings of 2'000 CHF. At the end of the first year, we have a total of 10'275 CHF in the pension fund, and 2'120 CHF in our investment portfolio for a total of 12'395 CHF.

#### Scenario 2 for one year

We deposit 10'000 CHF into our investment portfolio. At the end of the first year, we have a total of 10'600 CHF.

Looking at this result, it's clear that in the short run it's advantageous to deposit money into your pension fund. After one year you have 1'795 CHF more!

Let's step 10 years into the future and see what it looks like then. To do so, we will need to compound the investment return using the [future value](https://www.investopedia.com/terms/f/futurevalue.asp) calculation:

$$ FV = I \cdot (1 + R)^T $$

> Note: `I` here is the investment amount, `R` the interest rate, and T the number of years.

#### Scenario 1 for 10 years

Substituting the values for the assets in the pension fund yields:

`FV_p = 10'000 * (1 + 0.0275)^10`

`FV_p = 13'116.51`

And for the investment portfolio:

`FV_i = 2'000 * (1 + 0.06)^10`

`FV_i = 3'581.69`

Adding together the two components results in :

`FV_1 = FV_i + FV_p`

`FV_1 = 16'698.20`

#### Scenario 2 for 10 years

Substituting the values for the investment portfolio yields:

`FV_2 = 10'000 * (1 + 0.06)^10`

`FV_2 = 17'908.48`

We see that after 10 years, scenario 2 is in the lead, having yielded 1'210.28 more return. As time goes by, the difference will only increase, as the following table illustrates:

| Duration | Scenario 1    | Scenario 2     | Difference (S2 - S1)|
|----------|--------------:|---------------:|--------------:|
| 0        | CHF 12'000.00 | CHF 10'000.00  | CHF -2'000.00 |
| 5        | CHF 14'129.18 | CHF 13'382.26  | CHF -746.93   |
| 10       | CHF 16'698.21 | CHF 17'908.48  | CHF 1'210.27  |
| 15       | CHF 19'815.11 | CHF 23'965.58  | CHF 4'150.48  |
| 20       | CHF 23'618.56 | CHF 32'071.35  | CHF 8'452.80  |
| 25       | CHF 28'287.35 | CHF 42'918.71  | CHF 14'631.36 |
| 30       | CHF 34'053.00 | CHF 57'434.91  | CHF 23'381.91 |
| 35       | CHF 41'216.43 | CHF 76'860.87  | CHF 35'644.44 |
| 40       | CHF 50'170.18 | CHF 102'857.18 | CHF 52'687.00 |

This indicates that (given the assumptions above) during the first approximately 5 years, scenario 1 was clearly better, and at some point between 5 and 10 years, scenario 2 became the better scenario. In other words if a person were to retire within 5 years of purchasing into their pension fund, scenario 1 would be the more advantageous option [^4]. If only we could determine exactly when this point in time would be! By defining a formula for each scenario, we can determine when they are equal and hence the break-even point.

## A Model

Having seen an example, let's define the future value of each scenario after `n` years.

### Scenario 1

$$ FV_1 = P \cdot (1 + r_p)^n + (P \cdot T)(1 + r_i)^n $$

### Scenario 2

$$ FV_2 = P \cdot (1 + r_i)^n $$

### Break-even point

With these formulae, we can determine the break-even point as the point in time where both strategies have the same value.

$$ FV_1 = FV_2 $$

$$ P \cdot \left( 1 + r_p \right)^n + \left( P \cdot T \right) \left(1 + r_i \right)^n = P \cdot \left( 1 + r_i \right)^n $$

Now we can cross-cancel `P` and simplify to:

$$ \frac{1}{1 - T} = \left( \frac{1 + r_i}{1 + r_P} \right)^n $$

Taking the log on both sides results in:

$$ \log \left(\frac{1}{1 - T}\right) = n \log \left(\frac{1 + r_i}{1 + r_P}\right) $$

Solving for `n` results in:

$$ n = \frac{\log \left( \frac{1}{1 - T} \right)}{\log \left( \frac{1 + r_i}{1 + r_P} \right)} $$

This (somewhat complicated) formula will allow you to determine for yourself whether it makes sense for you to purchase into your pension fund or not. By plugging in your marginal tax rate, expected pension fund return, and expected investment return, you can decide whether scenario 1 or 2 is better for you.

Let's plug in our values from above:

`n = log(1 / (1 - 0.2)) / log((1 + 0.06)/(1 + 0.0275))`

`n = 7.165`

So after a bit more than 7 years, scenario 2 becomes better than scenario 1.

## Conclusion

I sought to answer the question "Should I purchase into my pension fund", and it turns out that the answer isn't clear cut, it depends on your own personal situation, in particular: how close you are to retirement, and how well you believe that you can invest your money.

I determined a formula which can be used to quite precisely answer the question, but assuming a modest annual return of 4% on your investments, a pension fund interest rate of 2%, and a marginal tax rate of 20% then the answer is "if you're within 12 years of retirement, it might be worth looking into it, otherwise don't purchase into your pension fund".

The following formula can be used to precisely determine whether you should deposit money into your pension fund or not:

`n = log(1 / (1 - T)) / log((1 + r_i)/(1 + r_p))`

Where `T` is your marginal tax rate, `r_i` the return you believe that _you_ can achieve by investing in the stock market, and `r_p` the interest rate of your pension fund.

By plugging in numbers which seem sensible to you, you can adopt it to your own personal situation.

If your retirement is within `n` years (and you plan on withdrawing all of your pension funds) then you should deposit money into your pension fund. If not, then you should not deposit money into your pension fund.

There are some additional conclusions which we can draw based on the structure of this formula:

- If you aren't into investing, and aren't interested in figuring it out (i.e. your `r_i` is zero), then you should definitely deposit into your pension fund.
- The more you earn, the greater your `T`, and hence the more you can get out purchasing into your pension fund.
- The more you believe in your power to beat your pension fund's return, the more you can get out of .

[^futurepost]: I am aware that I've skipped over a bunch of details. I have a blog post planned which goes more in depth on how pension funds work.

[^pkvergleich]: I kind of skipped over the fact that you also need to distinguish between the return that the pension fund made (on its assets), and the interest rate which is passed on to the insured. The returns are not passed on 100% because the pension funds are saving for a rainy day. The following pdf provides an overview of the _investment return_ of a number of pension funds for the period 2011-2020: <https://pensionskassenvergleich.ch/downloads/anlagerenditen_2021.pdf>. The following pdf provides an overview of the _interest rates_ by pension fund and year: <https://pensionskassenvergleich.ch/downloads/verzinsung_2021.pdf>

[^investopediasnp]: <https://www.investopedia.com/ask/answers/042415/what-average-annual-return-sp-500.asp>

[^moneyparksmi]: <https://www.moneyland.ch/en/swiss-stock-market-returns>

[^MTRT]: Surprisingly I was not able to find a source which presents the marginal tax rates directly, so I derived them using the canton of Zürich's [tax calculator](https://www.zh.ch/de/steuern-finanzen/steuern/steuern-natuerliche-personen/steuererklaerung-natuerliche-personen/steuerrechner.html?calculatorId=income_assets) with the following parameters: year 2021, single person, no dependents, no church, Gemeinde Zürich.

[^4]: Assuming the person would make a lump-sump withdrawal of their pension, which is in and of itself a valid question worth asking and answering, but this blog post is too long already!

