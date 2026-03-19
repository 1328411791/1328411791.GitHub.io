---
tags: [量化交易]
mermaid: true
date: 2025-10-18 16:17:11
---

# 踩坑

在使用 IBKR API 进行以及初步学习量化交易的过程中，我遇到了一些问题，特此记录下来以备后续参考。


# 环境配置

# 安装IBKR Gateway

安装官网上ibkr gateway应用（此应用作为沟通程序与IBKR服务器的桥梁），并配置好API访问权限。不使用TWS的原因是TWS功能过于复杂，且资源占用较高，ui有一种上世纪的美感。

地址：https://www.interactivebrokers.com/cn/trading/ibgateway-latest.php

![](https://pic.liahnu.top/img/202510181635896.png)


一些默认的配置
![](https://pic.liahnu.top/img/202510181638813.png)

推荐开一个ibkr的模拟账户进行测试，同时开一个子用户购买数据订阅服务，以免影响主账户的正常使用。

## 安装python库环境

## 安装 ib_async
ib_async 是一个第三方对接IBKR API的python库，功能完善且易用。

安装ib_async库，注意不是ib_insync，ib_insync已经被停止维护弃用，文档地址已经指引到ib_async中。

    官方文档：
    考虑到这一点，用户应该知道，原始ib_insync包是使用旧版TWS API构建的，不再更新。希望使用受支持的 Trader Workstation 版本实现ib_insync结构的用户应迁移到 ib_async 包 ，该包是由其原始开发人员之一对该包进行现代化实现。 


相关文档：
1. https://ib-api-reloaded.github.io/ib_async/notebooks.html
2. https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#non-tws-api-support

```python
pip install ib_async
```

## 安装官方api

部分应用可能需要安装官方api，这里提供官方api安装方法
https://www.interactivebrokers.com/campus/ibkr-api-page/twsapi-doc/#windows-install


盈透证券官方 API 仅通过其 Github 站点提供，而不是 Python 包索引 （PyPI），因为它是在不同的许可证下分发的。但是，您可以从提供的源代码构建一个轮子，然后安装轮子。这些是步骤：

1） 从 http://interactivebrokers.github.io/ 下载“API 最新” http://interactivebrokers.github.io/

2） 解压缩或安装（如果是.msi文件）下载。

3） 转到 tws-api/source/pythonclient/

4） 安装：

```shell
$  cd ~/TWS API/source/pythonclient
$  python3 setup.py install
```
在 TWS API\samples\Python 下有一些demo测试api是否已经安装


# 连接IBKR Gateway
使用ib_async连接IBKR Gateway，代码如下：

```python
    from ib_async import *
    ib = IB()
    ib.connect('127.0.0.1', 4002, clientId=991)
    logging.info("已连接到IBKR服务器")
```

注意：4002端口是IBKR Gateway的默认API端口，TWS的默认端口是7497。
端口可以在gateway的配置界面中查看和修改，clientId是用户自定义的一个标识符，可以随意设置，但同一时间只能有一个客户端使用同一个clientId连接到IBKR服务器，否则会导致连接失败。


## 常用api

    等我研究研究

## vnpy

vnpy是一个开源的量化交易框架，支持多种交易所和数据源，包括IBKR。它提供了丰富的功能和工具，适合用于构建和运行量化交易策略。

### 踩到的坑

1. vnpy-ib的安装，需要去clone vnpy-ib的的仓库，手动安装更新依赖，之后再安装protobuf

2. 使用vnpy-alpha的时候，需要安装alphalens依赖，使用pip install alphalens-reloaded安装最新版本，老版本的alphalens不兼容最新的python版本。

# 量化交易入门

量化交易的核心在于设计和实现一个有效的交易策略。

等我读一些文章再来写吧，我觉得对接api属于苦力活，难点还是在如何设计一个完善的交易策略上。这里简单的用tradeviewer的策略回测功能来验证一下交易策略的有效性。跑个demo策略。

## 某些神奇策略

记录一下从网上cp的或者不知道从哪来的神奇策略

## superTrend + QQE MOD + A-V2

某个趋势跟踪策略，使用superTrend指标，QQE MOD指标和A-V2指标的组合来生成交易信号。superTrend指标用于识别市场趋势，QQE MOD指标用于确认趋势的强度，A-V2指标用于捕捉价格的动量变化。用后面两个指标来过滤superTrend的信号，以减少假信号的出现。

```python
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © liahnu2003

//@version=5
strategy('supertrend + QQE MOD + A-V2', overlay=true)

// SuperTrend
group_supertrend = "SuperTrend Settings"
Periods = input(title='ATR Period', defval=9,group = group_supertrend)
src = input(hl2, title='Source',group = group_supertrend)
Multiplier = input.float(title='ATR Multiplier', step=0.1, defval=3.9,group = group_supertrend)
changeATR = input(title='Change ATR Calculation Method ?', defval=true,group = group_supertrend)
showsignals = input(title='Show Buy/Sell Signals ?', defval=true,group = group_supertrend)
highlighting = input(title='Highlighter On/Off ?', defval=true,group = group_supertrend)

// === PRIMARY QQE SETTINGS ===
group_primary = "Primary QQE Settings"
rsiLengthPrimary = input.int(6, title="RSI Length", group=group_primary)
rsiSmoothingPrimary = input.int(5, title="RSI Smoothing", group=group_primary)
qqeFactorPrimary = input.float(3.0, title="QQE Factor", group=group_primary)
thresholdPrimary = input.float(3.0, title="Threshold", group=group_primary)
sourcePrimary = input.source(close, title="RSI Source", group=group_primary)

// === SECONDARY QQE SETTINGS ===
group_secondary = "Secondary QQE Settings"
rsiLengthSecondary = input.int(6, title="RSI Length", group=group_secondary)
rsiSmoothingSecondary = input.int(5, title="RSI Smoothing", group=group_secondary)
qqeFactorSecondary = input.float(1.61, title="QQE Factor", group=group_secondary)
thresholdSecondary = input.float(3.0, title="Threshold", group=group_secondary)
sourceSecondary = input.source(close, title="RSI Source", group=group_secondary)

// === BOLLINGER BANDS SETTINGS ===
group_bollinger = "Bollinger Bands Settings"
bollingerLength = input.int(50, minval=1, title="Length", group=group_bollinger, tooltip="The length of the Bollinger Bands calculation.")
bollingerMultiplier = input.float(0.35, step=0.1, minval=0.001, maxval=5, title="Multiplier", group=group_bollinger, tooltip="The multiplier used to calculate Bollinger Band width.")

// A V2

ma_type = input.string('EMA', 'MA Type', ['ALMA','HMA','SMA','SWMA','VWMA','WMA','ZLEMA','EMA'], group = 'Setup')
ma_period = input.int(9, 'MA Period (Length)', 1, group='Setup')

alma_offset = input.float(0.85, 'ALMA Shift', 0, 1, 0.05, group = 'Setup (ALMA)')
alma_sigma = input.int(6, 'ALMA Deviation', 1, step = 1, group = 'Setup (ALMA)')

// 策略参数
group_strategy = "Strategy Settings"
use_stop_loss = input.bool(true, "使用止损", group=group_strategy)
stop_loss_percent = input.float(2.0, "止损百分比", minval=0.1, maxval=20, step=0.1, group=group_strategy)

// SuperTrend
atr2 = ta.sma(ta.tr, Periods)
atr = changeATR ? ta.atr(Periods) : atr2
up = src - Multiplier * atr
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up
dn = src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn
trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend
upPlot = plot(trend == 1 ? up : na, title='Up Trend', style=plot.style_linebr, linewidth=2, color=color.new(color.green, 0))
buySignal = trend == 1 and trend[1] == -1
plotshape(buySignal ? up : na, title='UpTrend Begins', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(color.green, 0))
plotshape(buySignal and showsignals ? up : na, title='Buy', text='Buy', location=location.absolute, style=shape.labelup, size=size.tiny, color=color.new(color.green, 0), textcolor=color.new(color.white, 0))
dnPlot = plot(trend == 1 ? na : dn, title='Down Trend', style=plot.style_linebr, linewidth=2, color=color.new(color.red, 0))
sellSignal = trend == -1 and trend[1] == 1
plotshape(sellSignal ? dn : na, title='DownTrend Begins', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(color.red, 0))
plotshape(sellSignal and showsignals ? dn : na, title='Sell', text='Sell', location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.new(color.red, 0), textcolor=color.new(color.white, 0))
mPlot = plot(ohlc4, title='', style=plot.style_circles, linewidth=0)
longFillColor = highlighting ? trend == 1 ? color.green : color.white : color.white
shortFillColor = highlighting ? trend == -1 ? color.red : color.white : color.white
fill(mPlot, upPlot, title='UpTrend Highligter', color=longFillColor, transp=90)
fill(mPlot, dnPlot, title='DownTrend Highligter', color=shortFillColor, transp=90)
alertcondition(buySignal, title='SuperTrend Buy', message='SuperTrend Buy!')
alertcondition(sellSignal, title='SuperTrend Sell', message='SuperTrend Sell!')
changeCond = trend != trend[1]
alertcondition(changeCond, title='SuperTrend Direction Change', message='SuperTrend has changed direction!')


// QQE MOD
calculateQQE(rsiLength, smoothingFactor, qqeFactor, source) =>
    wildersLength = rsiLength * 2 - 1
    rsi = ta.rsi(source, rsiLength)
    smoothedRsi = ta.ema(rsi, smoothingFactor)
    atrRsi = math.abs(smoothedRsi[1] - smoothedRsi)
    smoothedAtrRsi = ta.ema(atrRsi, wildersLength)
    dynamicAtrRsi = smoothedAtrRsi * qqeFactor

    // Initialize variables
    longBand = 0.0
    shortBand = 0.0
    trendDirection = 0

    // Calculate longBand, shortBand, and trendDirection
    atrDelta = dynamicAtrRsi
    newShortBand = smoothedRsi + atrDelta
    newLongBand = smoothedRsi - atrDelta
    longBand := smoothedRsi[1] > longBand[1] and smoothedRsi > longBand[1] ? math.max(longBand[1], newLongBand) : newLongBand
    shortBand := smoothedRsi[1] < shortBand[1] and smoothedRsi < shortBand[1] ? math.min(shortBand[1], newShortBand) : newShortBand
    longBandCross = ta.cross(longBand[1], smoothedRsi)
    
    if ta.cross(smoothedRsi, shortBand[1])
        trendDirection := 1
    else if longBandCross
        trendDirection := -1
    else
        trendDirection := trendDirection[1]

    // Determine the trend line
    qqeTrendLine = trendDirection == 1 ? longBand : shortBand
    [qqeTrendLine, smoothedRsi]

// === MAIN CALCULATIONS ===
// Calculate Primary QQE
[primaryQQETrendLine, primaryRSI] = calculateQQE(rsiLengthPrimary, rsiSmoothingPrimary, qqeFactorPrimary, sourcePrimary)

// Calculate Secondary QQE
[secondaryQQETrendLine, secondaryRSI] = calculateQQE(rsiLengthSecondary, rsiSmoothingSecondary, qqeFactorSecondary, sourceSecondary)

// Calculate Bollinger Bands for the Primary QQE Trend Line
bollingerBasis = ta.sma(primaryQQETrendLine - 50, bollingerLength)
bollingerDeviation = bollingerMultiplier * ta.stdev(primaryQQETrendLine - 50, bollingerLength)
bollingerUpper = bollingerBasis + bollingerDeviation
bollingerLower = bollingerBasis - bollingerDeviation

// Color Conditions for Primary RSI
rsiColorPrimary = primaryRSI - 50 > bollingerUpper ? color.blue : primaryRSI - 50 < bollingerLower ? color.red : color.new(#707070, 20)

// Color Conditions for Secondary RSI
rsiColorSecondary = secondaryRSI - 50 > thresholdSecondary ? color.new(#707070, 20) : secondaryRSI - 50 < -thresholdSecondary ? color.new(#707070, 20) : na

// === PLOTTING ===
// // Plot Primary and Secondary QQE Lines
// plot(secondaryQQETrendLine - 50, title="Secondary QQE Trend Line", color=color.white, linewidth=2)
// plot(secondaryRSI - 50, color=rsiColorSecondary, title="Secondary RSI Histogram", style=plot.style_columns)

// // Plot Signal Highlights
// plot(secondaryRSI - 50 > thresholdSecondary and primaryRSI - 50 > bollingerUpper ? secondaryRSI - 50 : na, title="QQE Up Signal", style=plot.style_columns, color=#00c3ff)
// plot(secondaryRSI - 50 < -thresholdSecondary and primaryRSI - 50 < bollingerLower ? secondaryRSI - 50 : na, title="QQE Down Signal", style=plot.style_columns, color=#ff0062)

// // Plot Zero Line
// hline(0, title="Zero Line", color=color.white, linestyle=hline.style_dotted)

show_line_1(x) =>
    input.bool(true, 'Show Close line', group = 'On/Off') ? x : na
show_line_2(x) =>
    input.bool(false, 'Show High/Low lines', group = 'On/Off') ? x : na
show_fill(x) =>
    input.bool(true, 'Show fill', group = 'On/Off') ? x : na
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Calculations :
f(x) =>
    switch ma_type
        'ALMA' => ta.alma(x, ma_period, alma_offset, alma_sigma)
        'HMA' => ta.hma(x, ma_period)
        'SMA' => ta.sma(x, ma_period)
        'SWMA' => ta.swma(x)
        'VWMA' => ta.vwma(x, ma_period)
        'WMA' => ta.vwma(x, ma_period)
        'ZLEMA' => ta.ema(x + x - x[math.floor((ma_period - 1) / 2)], ma_period)
        => ta.ema(x, ma_period)

ma_heikinashi_open = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open))
ma_heikinashi_close = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close))
ma_heikinashi_high = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, high))
ma_heikinashi_low = f(request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, low))

ma_trend = 100 * (ma_heikinashi_close - ma_heikinashi_open) / (ma_heikinashi_high - ma_heikinashi_low)
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Colors :
color_positive = input.color(color.new(#26A69A, 0), 'Positive color (Bullish)', group = 'Colors')
color_negative = input.color(color.new(#EF5350, 0), 'Negative color (Bearish)', group = 'Colors')
color_neutral = input.color(color.new(#808080, 0), 'Neutral color', group = 'Colors')

color_trend = ma_trend > 0 ? color_positive : color_negative
//╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
//║ Plot :
plot_open = plot(ma_heikinashi_open, 'Open line', na)
plot_close = plot(ma_heikinashi_close, 'Close line', show_line_1(color_trend), 2)
plot_high = plot(ma_heikinashi_high, 'High line', show_line_2(color_neutral))
plot_low = plot(ma_heikinashi_low, 'Low line', show_line_2(color_neutral))

plot_highest = plot(math.max(ma_heikinashi_open, ma_heikinashi_close),'Highest Body line', na)
plot_lowest = plot(math.min(ma_heikinashi_open, ma_heikinashi_close),'Lowest Body line', na)


// 策略逻辑
// 策略逻辑
// 定义多空仓位变量
var float long_entry_price = na
var bool in_long_trade = false
var float short_entry_price = na
var bool in_short_trade = false

// 计算止损价格（百分比止损）
long_stop_loss_price = use_stop_loss and in_long_trade ? long_entry_price * (1 - stop_loss_percent / 100) : na
short_stop_loss_price = use_stop_loss and in_short_trade ? short_entry_price * (1 + stop_loss_percent / 100) : na

// 买入信号条件
qqe_blue_bar = (rsiColorPrimary == color.blue) and (primaryRSI - 50 > 0)
av2_line = ma_heikinashi_close
enter_long_condition = buySignal and qqe_blue_bar and (color_trend == color_positive)

// 做空信号条件
qqe_red_bar = (rsiColorPrimary == color.red) and (primaryRSI - 50 < 0)
enter_short_condition = sellSignal and qqe_red_bar and (color_trend == color_negative)

// === 做多逻辑 ===
// 进入多头
if enter_long_condition
    strategy.entry("Long", strategy.long)
    long_entry_price := close
    in_long_trade := true
    in_short_trade := false  // 关闭空头仓位（如果存在）
    short_entry_price := na

// 多头止损条件：价格下穿AV2线
long_stop_loss_av2 = in_long_trade and ta.crossunder(close, av2_line)

// 多头百分比止损条件
long_stop_loss_percent_condition = use_stop_loss and in_long_trade and close <= long_stop_loss_price

// 多头平仓条件：满足任意止损条件
if (long_stop_loss_av2 or long_stop_loss_percent_condition) and in_long_trade
    strategy.close("Long")
    in_long_trade := false
    long_entry_price := na

// === 做空逻辑 ===
// 进入空头
if enter_short_condition
    strategy.entry("Short", strategy.short)
    short_entry_price := close
    in_short_trade := true
    in_long_trade := false  // 关闭多头仓位（如果存在）
    long_entry_price := na

// 空头止损条件：价格上穿AV2线
short_stop_loss_av2 = in_short_trade and ta.crossover(close, av2_line)

// 空头百分比止损条件
short_stop_loss_percent_condition = use_stop_loss and in_short_trade and close >= short_stop_loss_price

// 空头平仓条件：满足任意止损条件
if (short_stop_loss_av2 or short_stop_loss_percent_condition) and in_short_trade
    strategy.close("Short")
    in_short_trade := false
    short_entry_price := na
```

![](https://pic.liahnu.top/img/202601051904548.png)
回测下来比较抽象，收益不高，没有某些ytber讲的那么神奇，可能是参数没有调好吧，后续继续研究。