local radio = require('radio')

if #arg < 1 then
    io.stderr:write("Usage: " .. arg[0] .. " <frequency>\n")
    os.exit(1)
end

local frequency = tonumber(arg[1])
local offset = -200e3
local baudrate = 1200

local top = radio.CompositeBlock()
local source = radio.RtlSdrSource(frequency + offset, 1000000)
local tuner = radio.TunerBlock(offset, 12e3, 80)
local nbfm_demod = radio.NBFMDemodulator(3e3, 3e3)
local hilbert = radio.HilbertTransformBlock(129)
local translator = radio.FrequencyTranslatorBlock(-1700)
local afsk_filter = radio.LowpassFilterBlock(128, 750)
local afsk_demod = radio.FrequencyDiscriminatorBlock(5.0)
local data_filter = radio.LowpassFilterBlock(128, baudrate)
local clock_recoverer = radio.ZeroCrossingClockRecoveryBlock(baudrate)
local sampler = radio.SamplerBlock()
local bit_slicer = radio.SlicerBlock()
local bit_decoder = radio.DifferentialDecoderBlock(true)
local framer = radio.AX25FrameBlock()
local sink = radio.JSONSink()

local plot1 = radio.GnuplotSpectrumSink(2048, 'RF Spectrum', {yrange = {-120, -40}})
local plot2 = radio.GnuplotPlotSink(2048, 'Demodulated Bitstream', {yrange = {-0.2, 0.2}})

top:connect(source, tuner, nbfm_demod)
top:connect(nbfm_demod, hilbert, translator, afsk_filter, afsk_demod, data_filter, clock_recoverer)
top:connect(data_filter, 'out', sampler, 'data')
top:connect(clock_recoverer, 'out', sampler, 'clock')
top:connect(sampler, bit_slicer, bit_decoder, framer, sink)
top:connect(tuner, plot1)
top:connect(data_filter, plot2)
top:run()