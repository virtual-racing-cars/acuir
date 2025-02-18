-- Parser for MoTec ld files using LuaJIT FFI with corrected session extraction

local motec = { head = nil, channels = {} }

local ffi = require("ffi")

ffi.cdef([[
typedef struct {
    uint32_t ldmarker[1];       // "I4x" -> uint32_t + 4-byte padding
    char padding1[4];       // "20x"
    uint32_t chann_meta_ptr;
    uint32_t chann_data_ptr;
    char padding1[20];       // "20x"
    uint32_t event_ptr;      // "I"
    char padding2[24];       // "24x"
    uint16_t unknown1;       // "H"
    uint16_t unknown2;       // "H"
    uint16_t unknown3;       // "H"
    uint32_t device_serial;  // "I"
    char device_type[8];     // "8s"
    uint16_t device_version; // "H"
    uint16_t unknown4;       // "H"
    uint32_t num_channs;     // "I"
    char padding3[4];        // "4x"
    char date[16];           // "16s"
    char padding4[16];       // "16x"
    char time[16];           // "16s"
    char padding5[16];       // "16x"
    char driver[64];         // "64s"
    char vehicleid[64];      // "64s"
    char padding6[64];       // "64x"
    char venue[64];          // "64s"
    char padding7[64];       // "64x"
    char padding8[1024];     // "1024x"
    uint32_t enable_pro_logging; // "I"
    char padding9[66];       // "66x"
    char short_comment[64];  // "64s"
    char padding10[126];     // "126x"
} __attribute__((packed)) ldHead;

typedef struct {
    char name[64];
    char session[64];
    char comment[1024];
    uint16_t venue_ptr;
} __attribute__((packed)) ldEvent;

typedef struct {
    uint32_t prev_meta_ptr;
    uint32_t next_meta_ptr;
    uint32_t data_ptr;
    uint32_t data_len;
    uint16_t counter;
    uint16_t dtype_a;
    uint16_t dtype;
    uint16_t freq;
    int16_t shift;
    int16_t mul;
    int16_t scale;
    int16_t dec;
    char name[32];
    char short_name[8];
    char unit[12];
    char padding6[40];       // "64x"
} __attribute__((packed)) ldChan;
]])

function clean_string(data, max_length)
        local str = ffi.string(data, max_length):match("^[^%z]*")
        return str and str:match("%S.*") or ""
end

local function read_struct(file, struct_type)
        local size = ffi.sizeof(struct_type)
        local data = file:read(size)
        if not data or #data < size then return nil, "Failed to read " .. struct_type end
        local struct_obj = ffi.new(struct_type)
        ffi.copy(struct_obj, data, size)
        return struct_obj
end

local function read_ldfile(file_path)
        local file = io.open(file_path, "rb")
        if not file then error("Could not open file: " .. file_path) end

        -- Read Header
        motec.head = read_struct(file, "ldHead")

        -- print("Short Comment:", clean_string(head.short_comment, 64))
        -- print("Driver:", clean_string(head.driver, 64))
        -- print("Car:", clean_string(head.vehicleid, 64))
        -- print("Venue:", clean_string(head.venue, 64))
        -- print("Time:", clean_string(head.time, 64))
        -- print("Date:", clean_string(head.date, 64))

        -- Read Event properly using event_ptr instead of hardcoded lookup
        if motec.head.event_ptr > 0 then
                file:seek("set", motec.head.event_ptr)
                local event, err = read_struct(file, "ldEvent")
                if event then
                        -- print("Session:", clean_string(event.session, 64))
                else
                        print("Session could not be read from event structure")
                end
        else
                print("No valid event pointer found")
        end

        -- Read Channels
        local meta_ptr = motec.head.chann_meta_ptr

        for i = 1, motec.head.num_channs do
                if meta_ptr == 0 then break end
                file:seek("set", meta_ptr)
                local chan, err = read_struct(file, "ldChan")
                if not chan then break end

                if i then --string.find(clean_string(chan.name), "out") then
                        -- Read and output channel data
                        file:seek("set", chan.data_ptr)
                        local data = file:read(chan.data_len * ffi.sizeof("float"))
                        local data_array = ffi.new("float[?]", chan.data_len)
                        ffi.copy(data_array, data, chan.data_len * ffi.sizeof("float"))

                        -- print(
                        --         i,
                        --         "Channel:",
                        --         clean_string(chan.name, 32),
                        --         "Freq:",
                        --         chan.freq,
                        --         "Data Points:",
                        --         chan.data_len,
                        --         chan.scale
                        -- )
                        for j = 0, chan.data_len - 1 do
                                -- print("  ", data_array[j])
                        end

                        -- db:setMotecData(clean_string(chan.name), data_array)
                end

                table.insert(motec.channels, chan)
                -- print("Channel:", clean_string(chan.name, 32), "Freq:", chan.freq)
                meta_ptr = chan.next_meta_ptr
        end

        file:close()
end

local file =
        "C:\\Users\\willi\\OneDrive\\Documents\\Assetto Corsa\\telemetry\\imola\\vrc_formula_beta_2024_csp\\imola_&_vrc_formula_beta_2024_csp_&_Schmawlik_&_stint_45.ld"

read_ldfile(file)

function motec:readData(chan)
        local file = io.open(file, "rb")

        file:seek("set", chan.data_ptr)
        local data = file:read(chan.data_len * ffi.sizeof("float"))
        local data_array = ffi.new("float[?]", chan.data_len)
        ffi.copy(data_array, data, chan.data_len * ffi.sizeof("float"))

        file:close()

        return data_array
end

return motec
