--[[
    Gridfinity Drawer Optimizer & Gap Filler Pro
    Plugin para PrusaSlicer 3.0+
    Autor: 3DEMS (Author ID: 9d2f6477-ddc2-4189-b873-d0026dd7a4ef)
    Basado en el estándar abierto Gridfinity de Zack Freedman (Voidstar Lab, Licencia MIT)
--]]

info = {
    id = "gridfinity_drawer_optimizer",
    type = "project.plugin",
    title = "Gridfinity Drawer Optimizer",
    menu = "3DEMS/Gridfinity Drawer Optimizer",
    params = {
        {name = "drawer_width", label = "Ancho interior del cajón [mm]", type = "float", default = 210.0},
        {name = "drawer_depth", label = "Profundidad interior del cajón [mm]", type = "float", default = 210.0},
        {
            name = "part_mode",
            label = "Tipo de pieza a generar",
            type = "combobox",
            allowed_values = {
                "Base completa a medida para el cajón",
                "Solo suplementos (Gap Fillers independientes)",
                "Caja Gridfinity optimizada (Bin estándar)"
            }
        },
        {
            name = "alignment_x",
            label = "Distribución del Gap horizontal (Ancho)",
            type = "combobox",
            allowed_values = {
                "Centrado (Gap repartido a ambos lados)",
                "Pegado a la izquierda (Todo el gap a la derecha)",
                "Pegado a la derecha (Todo el gap a la izquierda)"
            }
        },
        {
            name = "alignment_y",
            label = "Distribución del Gap vertical (Fondo)",
            type = "combobox",
            allowed_values = {
                "Pegado al frente (Todo el gap al fondo)",
                "Centrado (Gap repartido frente y fondo)",
                "Pegado al fondo (Todo el gap al frente)"
            }
        },
        {
            name = "gap_treatment",
            label = "Función del Gap sobrante",
            type = "combobox",
            allowed_values = {
                "Borde espaciador plano (Anti-movimiento sólido)",
                "Bandeja longitudinal útil (Canal para herramientas largas)"
            }
        },
        {name = "base_height", label = "Altura de la base [mm]", type = "float", default = 5.0},
        {name = "magnet_holes", label = "Orificios para imanes 6x2 mm en esquinas", type = "bool", default = true}
    }
}

function execute(opts)
    opts = opts or {}
    local d_width = math.max(42.0, opts.drawer_width or 210.0)
    local d_depth = math.max(42.0, opts.drawer_depth or 210.0)
    local part_mode = opts.part_mode or "Base completa a medida para el cajón"
    local align_x = opts.alignment_x or "Centrado (Gap repartido a ambos lados)"
    local align_y = opts.alignment_y or "Pegado al frente (Todo el gap al fondo)"
    local gap_treatment = opts.gap_treatment or "Borde espaciador plano (Anti-movimiento sólido)"
    local base_h = math.max(4.0, opts.base_height or 5.0)
    local magnet_holes = (opts.magnet_holes ~= false)

    -- 1. Cálculo matemático de la cuadrícula óptima Gridfinity (42x42 mm)
    local PITCH = 42.0
    local nx = math.max(1, math.floor(d_width / PITCH))
    local ny = math.max(1, math.floor(d_depth / PITCH))
    local grid_w = nx * PITCH
    local grid_d = ny * PITCH
    local gap_x = math.max(0.0, d_width - grid_w)
    local gap_y = math.max(0.0, d_depth - grid_d)

    -- 2. Distribución configurable del Gap
    local pad_left = 0.0
    local pad_right = 0.0
    if string.find(align_x, "Centrado") then
        pad_left = gap_x / 2.0
        pad_right = gap_x / 2.0
    elseif string.find(align_x, "izquierda") then
        pad_left = 0.0
        pad_right = gap_x
    else
        pad_left = gap_x
        pad_right = 0.0
    end

    local pad_front = 0.0
    local pad_back = 0.0
    if string.find(align_y, "frente") then
        pad_front = 0.0
        pad_back = gap_y
    elseif string.find(align_y, "Centrado") then
        pad_front = gap_y / 2.0
        pad_back = gap_y / 2.0
    else
        pad_front = gap_y
        pad_back = 0.0
    end

    -- Resolver de forma segura el tipo de volumen negativo para imanes o ranuras
    local neg_type = nil
    pcall(function()
        if VolumeType and VolumeType.Negative then
            neg_type = VolumeType.Negative
        elseif api and api.VolumeType and api.VolumeType.Negative then
            neg_type = api.VolumeType.Negative
        elseif api and api.project and api.project.VolumeType and api.project.VolumeType.Negative then
            neg_type = api.project.VolumeType.Negative
        end
    end)

    local floor_thickness = 1.8
    local rib_height = base_h - floor_thickness
    local other_volumes = {}

    -- CASO 1: BASE COMPLETA AJUSTADA AL CAJÓN
    if string.find(part_mode, "completa") then
        -- Suelo continuo base de todo el cajón
        local base_mesh = api.make_cube(d_width, d_depth, floor_thickness)

        -- Marco de ajuste en los bordes (Gap Fillers perimetrales)
        local rim_h = rib_height

        -- Borde izquierdo si existe gap
        if pad_left > 0.5 then
            table.insert(other_volumes, {
                mesh = api.make_cube(pad_left, d_depth, rim_h),
                translate = { x = 0, y = 0, z = floor_thickness }
            })
        end

        -- Borde derecho si existe gap
        if pad_right > 0.5 then
            table.insert(other_volumes, {
                mesh = api.make_cube(pad_right, d_depth, rim_h),
                translate = { x = d_width - pad_right, y = 0, z = floor_thickness }
            })
        end

        -- Borde frontal si existe gap
        if pad_front > 0.5 then
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w, pad_front, rim_h),
                translate = { x = pad_left, y = 0, z = floor_thickness }
            })
        end

        -- Borde trasero (Fondo) si existe gap
        if pad_back > 0.5 then
            local is_trough = string.find(gap_treatment, "longitudinal") and (pad_back >= 14.0)
            if is_trough and neg_type then
                -- Bloque macizo elevado con canal útil vaciado
                local trough_wall = 1.6
                local trough_h = math.max(rim_h, 8.0)
                table.insert(other_volumes, {
                    mesh = api.make_cube(grid_w, pad_back, trough_h),
                    translate = { x = pad_left, y = d_depth - pad_back, z = floor_thickness }
                })
                -- Vaciado interior de la bandeja longitudinal
                local slot_w = grid_w - (trough_wall * 2)
                local slot_d = pad_back - (trough_wall * 2)
                table.insert(other_volumes, {
                    mesh = api.make_cube(slot_w, slot_d, trough_h),
                    type = neg_type,
                    translate = {
                        x = pad_left + trough_wall,
                        y = d_depth - pad_back + trough_wall,
                        z = floor_thickness + 1.2
                    }
                })
            else
                -- Borde plano sólido estándar
                table.insert(other_volumes, {
                    mesh = api.make_cube(grid_w, pad_back, rim_h),
                    translate = { x = pad_left, y = d_depth - pad_back, z = floor_thickness }
                })
            end
        end

        -- Rejilla interior Gridfinity: Nervaduras elevadas de 2.6 mm entre celdas
        local rib_w = 2.6
        -- Nervaduras horizontales
        for row = 0, ny do
            local y_pos = pad_front + (row * PITCH) - (row == 0 and 0 or (row == ny and rib_w or (rib_w / 2)))
            local actual_w = (row == 0 or row == ny) and rib_w or rib_w
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w, actual_w, rib_h),
                translate = { x = pad_left, y = y_pos, z = floor_thickness }
            })
        end
        -- Nervaduras verticales
        for col = 0, nx do
            local x_pos = pad_left + (col * PITCH) - (col == 0 and 0 or (col == nx and rib_w or (rib_w / 2)))
            local actual_w = (col == 0 or col == nx) and rib_w or rib_w
            table.insert(other_volumes, {
                mesh = api.make_cube(actual_w, grid_d, rib_h),
                translate = { x = x_pos, y = pad_front, z = floor_thickness }
            })
        end

        -- Orificios de imán de 6x2 mm (radio 3.1 mm) en las esquinas de cada celda si están activados
        if magnet_holes and neg_type then
            local mag_r = 3.1
            local mag_h = 2.4
            local mag_offset = 8.0
            for col = 1, nx do
                for row = 1, ny do
                    local cell_cx = pad_left + (col - 0.5) * PITCH
                    local cell_cy = pad_front + (row - 0.5) * PITCH
                    local corners = {
                        {x = cell_cx - (PITCH/2 - mag_offset), y = cell_cy - (PITCH/2 - mag_offset)},
                        {x = cell_cx + (PITCH/2 - mag_offset), y = cell_cy - (PITCH/2 - mag_offset)},
                        {x = cell_cx - (PITCH/2 - mag_offset), y = cell_cy + (PITCH/2 - mag_offset)},
                        {x = cell_cx + (PITCH/2 - mag_offset), y = cell_cy + (PITCH/2 - mag_offset)}
                    }
                    for _, c in ipairs(corners) do
                        table.insert(other_volumes, {
                            mesh = api.make_cylinder(mag_r, mag_h),
                            type = neg_type,
                            translate = { x = c.x, y = c.y, z = 0 }
                        })
                    end
                end
            end
        end

        -- Añadir el conjunto a la bandeja de PrusaSlicer
        api.project:add_object {
            mesh = base_mesh,
            other_volumes = other_volumes
        }

    -- CASO 2: SOLO SUPLEMENTOS (GAP FILLERS INDEPENDIENTES)
    elseif string.find(part_mode, "suplementos") then
        local filler_w = (pad_left + pad_right > 0) and (pad_left + pad_right) or 15.0
        local filler_d = (pad_back > 0) and pad_back or 20.0
        local base_mesh = api.make_cube(grid_w, filler_d, base_h)

        if string.find(gap_treatment, "longitudinal") and neg_type and filler_d >= 14.0 then
            local trough_wall = 1.6
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w - (trough_wall * 2), filler_d - (trough_wall * 2), base_h),
                type = neg_type,
                translate = { x = trough_wall, y = trough_wall, z = 1.6 }
            })
        end

        api.project:add_object {
            mesh = base_mesh,
            other_volumes = other_volumes
        }

    -- CASO 3: CAJA MODULAR OPTIMIZADA (BIN)
    else
        local bin_units_x = 2
        local bin_units_y = 2
        local bin_w = (bin_units_x * PITCH) - 0.5
        local bin_d = (bin_units_y * PITCH) - 0.5
        local bin_h = 28.0 -- 4U
        local wall = 1.2

        local base_mesh = api.make_cube(bin_w, bin_d, bin_h)

        if neg_type then
            -- Vaciado interior de la caja
            table.insert(other_volumes, {
                mesh = api.make_cube(bin_w - (wall * 2), bin_d - (wall * 2), bin_h),
                type = neg_type,
                translate = { x = wall, y = wall, z = 2.0 }
            })
        end

        api.project:add_object {
            mesh = base_mesh,
            other_volumes = other_volumes
        }
    end
end
