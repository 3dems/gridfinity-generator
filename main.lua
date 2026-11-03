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
        {name = "drawer_width", label = "1. Ancho interior del cajon [mm]", type = "float", default = 210.0},
        {name = "drawer_depth", label = "2. Profundidad interior del cajon [mm]", type = "float", default = 210.0},
        {
            name = "grid_pitch_type",
            label = "3. Tamano de cuadricula (Grid Pitch)",
            type = "combobox",
            allowed_values = {
                "42 mm - Gridfinity Estandar (Universal)",
                "21 mm - Micro-Grid (Minimiza el gap, piezas pequenas)",
                "28 mm - Mini-Grid (Cajones compactos)",
                "50 mm - Industrial / Systainer (Metrico)",
                "63 mm - Medium-Grid (1.5x)",
                "84 mm - Macro-Grid (2x para herramientas grandes)",
                "Personalizado (utiliza el valor de abajo)"
            }
        },
        {name = "custom_pitch", label = "4. Paso personalizado [mm] (si se eligio personalizado)", type = "float", default = 42.0},
        {
            name = "profile_thickness",
            label = "5. Grosor y estilo de la base (Fino / Grueso)",
            type = "combobox",
            allowed_values = {
                "Estandar (5.0 mm - Ranura normal e imanes)",
                "Fino / Eco-Lite (2.8 mm - Ahorra 50% tiempo y filamento)",
                "Grueso / Reforzado (7.0 mm - Taller y herramientas pesadas)"
            }
        },
        {
            name = "part_mode",
            label = "6. Tipo de pieza a generar",
            type = "combobox",
            allowed_values = {
                "Base completa a medida para el cajon",
                "Solo suplementos (Gap Fillers independientes)",
                "Caja Gridfinity optimizada (Bin a juego)"
            }
        },
        {
            name = "alignment_x",
            label = "7. Distribucion del Gap horizontal (Ancho)",
            type = "combobox",
            allowed_values = {
                "Centrado (Gap repartido a ambos lados)",
                "Pegado a la izquierda (Todo el gap a la derecha)",
                "Pegado a la derecha (Todo el gap a la izquierda)"
            }
        },
        {
            name = "alignment_y",
            label = "8. Distribucion del Gap vertical (Fondo)",
            type = "combobox",
            allowed_values = {
                "Pegado al frente (Todo el gap al fondo)",
                "Centrado (Gap repartido frente y fondo)",
                "Pegado al fondo (Todo el gap al frente)"
            }
        },
        {
            name = "gap_treatment",
            label = "9. Funcion del Gap sobrante",
            type = "combobox",
            allowed_values = {
                "Borde espaciador plano (Anti-movimiento solido)",
                "Bandeja longitudinal util (Canal para herramientas largas)"
            }
        },
        {name = "magnet_holes", label = "10. Orificios para imanes 6x2 mm en esquinas", type = "bool", default = true},
        {name = "emboss_info_label", label = "11. Grabar etiqueta con medidas y gap en la base", type = "bool", default = true}
    }
}

function execute(opts)
    opts = opts or {}
    local d_width = math.max(20.0, opts.drawer_width or 210.0)
    local d_depth = math.max(20.0, opts.drawer_depth or 210.0)
    local pitch_choice = opts.grid_pitch_type or "42 mm - Gridfinity Estandar (Universal)"
    local custom_pitch_val = math.max(10.0, opts.custom_pitch or 42.0)
    local profile_choice = opts.profile_thickness or "Estandar (5.0 mm - Ranura normal e imanes)"
    local part_mode = opts.part_mode or "Base completa a medida para el cajon"
    local align_x = opts.alignment_x or "Centrado (Gap repartido a ambos lados)"
    local align_y = opts.alignment_y or "Pegado al frente (Todo el gap al fondo)"
    local gap_treatment = opts.gap_treatment or "Borde espaciador plano (Anti-movimiento solido)"
    local magnet_holes = (opts.magnet_holes ~= false)
    local emboss_info = (opts.emboss_info_label ~= false)

    -- 1. Determinación del Pitch según la opción seleccionada
    local PITCH = 42.0
    if string.find(pitch_choice, "21 mm") then
        PITCH = 21.0
    elseif string.find(pitch_choice, "28 mm") then
        PITCH = 28.0
    elseif string.find(pitch_choice, "50 mm") then
        PITCH = 50.0
    elseif string.find(pitch_choice, "63 mm") then
        PITCH = 63.0
    elseif string.find(pitch_choice, "84 mm") then
        PITCH = 84.0
    elseif string.find(pitch_choice, "Personalizado") then
        PITCH = custom_pitch_val
    else
        PITCH = 42.0
    end

    -- 2. Determinación de grosores según el estilo (Fino / Estándar / Reforzado)
    local floor_thickness = 1.8
    local base_h = 5.0
    if string.find(profile_choice, "Fino") then
        floor_thickness = 1.0
        base_h = 2.8
    elseif string.find(profile_choice, "Grueso") or string.find(profile_choice, "Reforzado") then
        floor_thickness = 2.4
        base_h = 7.0
    else
        floor_thickness = 1.8
        base_h = 5.0
    end
    local rib_height = base_h - floor_thickness

    -- 3. Cálculo matemático de cuadrícula y Gaps
    local nx = math.max(1, math.floor(d_width / PITCH))
    local ny = math.max(1, math.floor(d_depth / PITCH))
    local grid_w = nx * PITCH
    local grid_d = ny * PITCH
    local gap_x = math.max(0.0, d_width - grid_w)
    local gap_y = math.max(0.0, d_depth - grid_d)

    -- 4. Distribución del Gap horizontal
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

    -- 5. Distribución del Gap vertical
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

    -- Resolver volumen negativo de forma segura
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

    local other_volumes = {}

    -- CASO 1: BASE COMPLETA AJUSTADA AL CAJÓN
    if string.find(part_mode, "completa") then
        local base_mesh = api.make_cube(d_width, d_depth, floor_thickness)
        local rim_h = rib_height

        -- Suplemento lateral izquierdo
        if pad_left > 0.5 then
            table.insert(other_volumes, {
                mesh = api.make_cube(pad_left, d_depth, rim_h),
                translate = { x = 0, y = 0, z = floor_thickness }
            })
        end

        -- Suplemento lateral derecho
        if pad_right > 0.5 then
            table.insert(other_volumes, {
                mesh = api.make_cube(pad_right, d_depth, rim_h),
                translate = { x = d_width - pad_right, y = 0, z = floor_thickness }
            })
        end

        -- Suplemento frontal
        if pad_front > 0.5 then
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w, pad_front, rim_h),
                translate = { x = pad_left, y = 0, z = floor_thickness }
            })
        end

        -- Suplemento fondo / trasero
        if pad_back > 0.5 then
            local is_trough = string.find(gap_treatment, "longitudinal") and (pad_back >= 14.0)
            if is_trough and neg_type then
                local trough_wall = 1.6
                local trough_h = math.max(rim_h, 8.0)
                table.insert(other_volumes, {
                    mesh = api.make_cube(grid_w, pad_back, trough_h),
                    translate = { x = pad_left, y = d_depth - pad_back, z = floor_thickness }
                })
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
                table.insert(other_volumes, {
                    mesh = api.make_cube(grid_w, pad_back, rim_h),
                    translate = { x = pad_left, y = d_depth - pad_back, z = floor_thickness }
                })
            end
        end

        -- Nervaduras Gridfinity adaptativas según el Pitch
        local rib_w = math.max(1.6, math.min(3.2, PITCH * 0.065))
        -- Nervaduras horizontales
        for row = 0, ny do
            local y_pos = pad_front + (row * PITCH) - (row == 0 and 0 or (row == ny and rib_w or (rib_w / 2)))
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w, rib_w, rib_h),
                translate = { x = pad_left, y = y_pos, z = floor_thickness }
            })
        end
        -- Nervaduras verticales
        for col = 0, nx do
            local x_pos = pad_left + (col * PITCH) - (col == 0 and 0 or (col == nx and rib_w or (rib_w / 2)))
            table.insert(other_volumes, {
                mesh = api.make_cube(rib_w, grid_d, rib_h),
                translate = { x = x_pos, y = pad_front, z = floor_thickness }
            })
        end

        -- Orificios de imán (sólo si no es perfil ultradelgado y pitch >= 30)
        if magnet_holes and neg_type and base_h >= 4.0 and PITCH >= 30.0 then
            local mag_r = 3.1
            local mag_h = 2.4
            local mag_offset = math.min(8.0, PITCH * 0.2)
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

        -- Grabado de texto informativo en el borde
        if emboss_info and api.emboss_text and api.get_default_font then
            pcall(function()
                local label_str = string.format("%dx%d [%.0fmm] Gap: %.1fx%.1fmm", nx, ny, PITCH, gap_x, gap_y)
                local txt_mesh = api.emboss_text {
                    font = api.get_default_font(),
                    text = label_str,
                    depth = 0.6
                }
                table.insert(other_volumes, {
                    mesh = txt_mesh,
                    translate = { x = pad_left + 4.0, y = math.max(1.0, pad_front - 3.0), z = floor_thickness }
                })
            end)
        end

        api.project:add_object {
            mesh = base_mesh,
            other_volumes = other_volumes
        }

    -- CASO 2: SOLO SUPLEMENTOS
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

    -- CASO 3: CAJA A JUEGO (BIN)
    else
        local bin_units_x = math.min(2, nx)
        local bin_units_y = math.min(2, ny)
        local bin_w = (bin_units_x * PITCH) - 0.5
        local bin_d = (bin_units_y * PITCH) - 0.5
        local bin_h = (PITCH <= 25.0) and 18.0 or 28.0
        local wall = (PITCH <= 25.0) and 0.8 or 1.2

        local base_mesh = api.make_cube(bin_w, bin_d, bin_h)

        if neg_type then
            table.insert(other_volumes, {
                mesh = api.make_cube(bin_w - (wall * 2), bin_d - (wall * 2), bin_h),
                type = neg_type,
                translate = { x = wall, y = wall, z = 1.6 }
            })
        end

        api.project:add_object {
            mesh = base_mesh,
            other_volumes = other_volumes
        }
    end
end