--[[
    Gridfinity Drawer Optimizer & Gap Filler Pro
    Plugin oficial para PrusaSlicer 3.0+
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
            name = "part_mode",
            label = "3. Tipo de pieza a generar",
            type = "combobox",
            default = "Base completa con cuadricula y ajuste a cajon",
            allowed_values = {
                "Base completa con cuadricula y ajuste a cajon",
                "Caja Gridfinity apilable (Bin con base Gridfinity)",
                "Solo suplementos perimetrales (Gap Fillers independientes)"
            }
        },
        {
            name = "bin_units_x",
            label = "4. Celdas de ancho para la caja (si eligio Caja)",
            type = "combobox",
            default = "2 celdas",
            allowed_values = {
                "1 celda",
                "2 celdas",
                "3 celdas",
                "4 celdas",
                "Ajustar al ancho util del cajon"
            }
        },
        {
            name = "bin_units_y",
            label = "5. Celdas de fondo para la caja (si eligio Caja)",
            type = "combobox",
            default = "2 celdas",
            allowed_values = {
                "1 celda",
                "2 celdas",
                "3 celdas",
                "4 celdas",
                "Ajustar al fondo util del cajon"
            }
        },
        {
            name = "bin_height_mode",
            label = "6. Altura de la caja (si eligio Caja)",
            type = "combobox",
            default = "6U - 42 mm (Estandar Gridfinity)",
            allowed_values = {
                "2U - 14 mm (Ultra compacta)",
                "3U - 21 mm (Perfil bajo)",
                "4U - 28 mm (Perfil medio)",
                "6U - 42 mm (Estandar Gridfinity)",
                "9U - 63 mm (Alta)",
                "12U - 84 mm (Profunda)"
            }
        },
        {
            name = "grid_pitch_type",
            label = "7. Tamano del modulo (Grid Pitch)",
            type = "combobox",
            default = "42 mm - Gridfinity Estandar (Universal)",
            allowed_values = {
                "42 mm - Gridfinity Estandar (Universal)",
                "21 mm - Micro-Grid (Piezas pequenas, minimiza el gap)",
                "28 mm - Mini-Grid (Cajones compactos)",
                "50 mm - Industrial / Systainer (Metrico)",
                "63 mm - Medium-Grid (1.5x)",
                "84 mm - Macro-Grid (2x para herramientas grandes)",
                "Personalizado (utiliza el valor inferior)"
            }
        },
        {name = "custom_pitch", label = "8. Paso personalizado [mm] (si se eligio personalizado)", type = "float", default = 42.0},
        {
            name = "profile_thickness",
            label = "9. Perfil y grosor de la base",
            type = "combobox",
            default = "Estandar (Altura 4.8 mm, ranura completa e imanes)",
            allowed_values = {
                "Estandar (Altura 4.8 mm, ranura completa e imanes)",
                "Fino / Eco-Lite (Altura 2.8 mm, ahorra 50% filamento y tiempo)",
                "Grueso / Reforzado (Altura 7.0 mm, para taller y herramientas)"
            }
        },
        {
            name = "alignment_x",
            label = "10. Distribucion del Gap horizontal (Ancho)",
            type = "combobox",
            default = "Centrado (Gap repartido a ambos lados)",
            allowed_values = {
                "Centrado (Gap repartido a ambos lados)",
                "Pegado a la izquierda (Todo el gap a la derecha)",
                "Pegado a la derecha (Todo el gap a la izquierda)"
            }
        },
        {
            name = "alignment_y",
            label = "11. Distribucion del Gap vertical (Fondo)",
            type = "combobox",
            default = "Pegado al frente (Todo el gap al fondo)",
            allowed_values = {
                "Pegado al frente (Todo el gap al fondo)",
                "Centrado (Gap repartido frente y fondo)",
                "Pegado al fondo (Todo el gap al frente)"
            }
        },
        {
            name = "gap_treatment",
            label = "12. Funcion del Gap sobrante",
            type = "combobox",
            default = "Borde espaciador plano (Anti-movimiento solido)",
            allowed_values = {
                "Borde espaciador plano (Anti-movimiento solido)",
                "Bandeja longitudinal util (Canal para herramientas largas)"
            }
        },
        {name = "magnet_holes", label = "13. Orificios para imanes 6x2 mm en cada celda", type = "bool", default = true},
        {name = "emboss_info_label", label = "14. Grabar medidas y gap en relieve sobre la base", type = "bool", default = true}
    }
}

function execute(opts)
    opts = opts or {}
    local d_width = math.max(20.0, opts.drawer_width or 210.0)
    local d_depth = math.max(20.0, opts.drawer_depth or 210.0)
    local part_mode_opt = opts.part_mode
    local pitch_choice = opts.grid_pitch_type or "42 mm"
    local custom_pitch_val = math.max(10.0, opts.custom_pitch or 42.0)
    local profile_choice = opts.profile_thickness or "Estandar"
    local align_x = opts.alignment_x or "Centrado"
    local align_y = opts.alignment_y or "frente"
    local gap_treatment = opts.gap_treatment or "plano"
    local magnet_holes = (opts.magnet_holes ~= false)
    local emboss_info = (opts.emboss_info_label ~= false)

    -- 1. Determinar el modo de pieza de forma ultra-robusta
    local is_bin = false
    local is_fillers_only = false
    local pm_str = tostring(part_mode_opt or "")
    if string.find(pm_str, "Caja") or string.find(pm_str, "Bin") then
        is_bin = true
    elseif string.find(pm_str, "suplemento") or string.find(pm_str, "Filler") then
        is_fillers_only = true
    elseif type(part_mode_opt) == "number" then
        if part_mode_opt == 1 then is_bin = true
        elseif part_mode_opt == 2 then is_fillers_only = true end
    end

    -- 2. Determinación del Pitch (Paso del módulo)
    local PITCH = 42.0
    local pitch_str = tostring(pitch_choice)
    if string.find(pitch_str, "21 mm") then
        PITCH = 21.0
    elseif string.find(pitch_str, "28 mm") then
        PITCH = 28.0
    elseif string.find(pitch_str, "50 mm") then
        PITCH = 50.0
    elseif string.find(pitch_str, "63 mm") then
        PITCH = 63.0
    elseif string.find(pitch_str, "84 mm") then
        PITCH = 84.0
    elseif string.find(pitch_str, "Personalizado") then
        PITCH = custom_pitch_val
    else
        PITCH = 42.0
    end

    -- 3. Alturas y grosores de base
    local floor_thickness = 1.4
    local base_h = 4.8
    local prof_str = tostring(profile_choice)
    if string.find(prof_str, "Fino") then
        floor_thickness = 1.0
        base_h = 2.8
    elseif string.find(prof_str, "Grueso") or string.find(prof_str, "Reforzado") then
        floor_thickness = 2.2
        base_h = 7.0
    else
        floor_thickness = 1.4
        base_h = 4.8
    end
    local wall_h = base_h - floor_thickness

    -- 4. Cálculo matemático de la cuadrícula
    local nx = math.max(1, math.floor(d_width / PITCH))
    local ny = math.max(1, math.floor(d_depth / PITCH))
    local grid_w = nx * PITCH
    local grid_d = ny * PITCH
    local gap_x = math.max(0.0, d_width - grid_w)
    local gap_y = math.max(0.0, d_depth - grid_d)

    -- 5. Distribución del Gap horizontal
    local pad_left = 0.0
    local pad_right = 0.0
    local ax_str = tostring(align_x)
    if string.find(ax_str, "izquierda") then
        pad_left = 0.0
        pad_right = gap_x
    elseif string.find(ax_str, "derecha") then
        pad_left = gap_x
        pad_right = 0.0
    else -- Centrado por defecto
        pad_left = gap_x / 2.0
        pad_right = gap_x / 2.0
    end

    -- 6. Distribución del Gap vertical
    local pad_front = 0.0
    local pad_back = 0.0
    local ay_str = tostring(align_y)
    if string.find(ay_str, "fondo") then
        pad_front = gap_y
        pad_back = 0.0
    elseif string.find(ay_str, "Centrado") then
        pad_front = gap_y / 2.0
        pad_back = gap_y / 2.0
    else -- Pegado al frente por defecto
        pad_front = 0.0
        pad_back = gap_y
    end

    -- Resolución de VolumeType.Negative de forma segura
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

    ----------------------------------------------------------------------------
    -- CASO A: CAJA MODULAR GRIDFINITY (BIN CON BASE GRIDFINITY REAL)
    ----------------------------------------------------------------------------
    if is_bin then
        -- 1. Unidades de ancho y fondo
        local bin_nx = 2
        local bin_ny = 2
        local bx_str = tostring(opts.bin_units_x or "2")
        if string.find(bx_str, "1") then bin_nx = 1
        elseif string.find(bx_str, "3") then bin_nx = 3
        elseif string.find(bx_str, "4") then bin_nx = 4
        elseif string.find(bx_str, "cajon") then bin_nx = math.max(1, nx)
        else bin_nx = 2 end

        local by_str = tostring(opts.bin_units_y or "2")
        if string.find(by_str, "1") then bin_ny = 1
        elseif string.find(by_str, "3") then bin_ny = 3
        elseif string.find(by_str, "4") then bin_ny = 4
        elseif string.find(by_str, "cajon") then bin_ny = math.max(1, ny)
        else bin_ny = 2 end

        -- 2. Altura en unidades Gridfinity (1U = 7mm)
        local bin_h = 42.0 -- 6U estándar
        local bh_str = tostring(opts.bin_height_mode or "6U")
        if string.find(bh_str, "2U") then bin_h = 14.0
        elseif string.find(bh_str, "3U") then bin_h = 21.0
        elseif string.find(bh_str, "4U") then bin_h = 28.0
        elseif string.find(bh_str, "9U") then bin_h = 63.0
        elseif string.find(bh_str, "12U") then bin_h = 84.0
        else bin_h = 42.0 end
        if PITCH <= 25.0 then bin_h = math.max(14.0, bin_h * 0.6) end

        -- Dimensiones estándar Gridfinity
        local bin_w = (bin_nx * PITCH) - 0.5
        local bin_d = (bin_ny * PITCH) - 0.5
        local foot_h = 4.4
        local foot_size = math.min(37.0, PITCH - 5.0)
        local wall_thick = (PITCH <= 25.0) and 1.2 or 1.6
        local floor_thick = 2.0

        -- CUERPO PRINCIPAL SÓLIDO (DESCANSA EN LA CAMA A Z = 0)
        local main_box = api.make_cube(bin_w, bin_d, bin_h)

        if neg_type then
            local cut_x = 2.25
            local cut_y = 2.25
            local chan_w = 5.0

            -- A. Rebaje perimetral inferior para dejar los pies Gridfinity (Z = 0 a foot_h)
            -- Izquierda y derecha
            table.insert(other_volumes, {
                mesh = api.make_cube(cut_x, bin_d, foot_h),
                type = neg_type,
                translate = { x = 0, y = 0, z = 0 }
            })
            table.insert(other_volumes, {
                mesh = api.make_cube(cut_x, bin_d, foot_h),
                type = neg_type,
                translate = { x = bin_w - cut_x, y = 0, z = 0 }
            })
            -- Frente y fondo
            table.insert(other_volumes, {
                mesh = api.make_cube(bin_w - (cut_x * 2), cut_y, foot_h),
                type = neg_type,
                translate = { x = cut_x, y = 0, z = 0 }
            })
            table.insert(other_volumes, {
                mesh = api.make_cube(bin_w - (cut_x * 2), cut_y, foot_h),
                type = neg_type,
                translate = { x = cut_x, y = bin_d - cut_y, z = 0 }
            })

            -- B. Canales divisores entre columnas de pies (si tiene 2 o más celdas)
            if bin_nx > 1 then
                for col = 1, bin_nx - 1 do
                    local ch_x = cut_x + (col * PITCH) - chan_w
                    table.insert(other_volumes, {
                        mesh = api.make_cube(chan_w, bin_d - (cut_y * 2), foot_h),
                        type = neg_type,
                        translate = { x = ch_x, y = cut_y, z = 0 }
                    })
                end
            end

            -- C. Canales divisores entre filas de pies (si tiene 2 o más celdas)
            if bin_ny > 1 then
                for row = 1, bin_ny - 1 do
                    local ch_y = cut_y + (row * PITCH) - chan_w
                    table.insert(other_volumes, {
                        mesh = api.make_cube(bin_w - (cut_x * 2), chan_w, foot_h),
                        type = neg_type,
                        translate = { x = cut_x, y = ch_y, z = 0 }
                    })
                end
            end

            -- D. Orificios cilíndricos para imanes en cada pie (Z = 0 a mag_depth)
            if magnet_holes and PITCH >= 28.0 then
                local mag_r = 3.25
                local mag_d = 2.4
                local m_offset = 13.0 * (PITCH / 42.0)
                for col = 1, bin_nx do
                    for row = 1, bin_ny do
                        local cell_cx = cut_x + ((col - 1) * PITCH) + (foot_size / 2.0)
                        local cell_cy = cut_y + ((row - 1) * PITCH) + (foot_size / 2.0)
                        local mag_corners = {
                            {x = cell_cx - m_offset, y = cell_cy - m_offset},
                            {x = cell_cx + m_offset, y = cell_cy - m_offset},
                            {x = cell_cx - m_offset, y = cell_cy + m_offset},
                            {x = cell_cx + m_offset, y = cell_cy + m_offset}
                        }
                        for _, mc in ipairs(mag_corners) do
                            table.insert(other_volumes, {
                                mesh = api.make_cylinder(mag_r, mag_d),
                                type = neg_type,
                                translate = { x = mc.x, y = mc.y, z = 0 }
                            })
                        end
                    end
                end
            end

            -- E. Vaciado interior de la caja (desde encima del suelo hasta la parte superior)
            local cav_z = foot_h + floor_thick
            local cav_w = bin_w - (wall_thick * 2)
            local cav_d = bin_d - (wall_thick * 2)
            local cav_h = bin_h - cav_z + 1.0
            if cav_h > 2.0 and cav_w > 5.0 and cav_d > 5.0 then
                table.insert(other_volumes, {
                    mesh = api.make_cube(cav_w, cav_d, cav_h),
                    type = neg_type,
                    translate = { x = wall_thick, y = wall_thick, z = cav_z }
                })
            end
        end

        api.project:add_object {
            mesh = main_box,
            other_volumes = other_volumes
        }
        return
    end

    ----------------------------------------------------------------------------
    -- CASO B: SOLO SUPLEMENTOS (GAP FILLERS INDEPENDIENTES)
    ----------------------------------------------------------------------------
    if is_fillers_only then
        local filler_w = (pad_left + pad_right > 0) and (pad_left + pad_right) or 20.0
        local filler_d = (pad_back > 0) and pad_back or 25.0
        local base_mesh = api.make_cube(grid_w, filler_d, base_h)

        if string.find(tostring(gap_treatment), "longitudinal") and neg_type and filler_d >= 14.0 then
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
        return
    end

    ----------------------------------------------------------------------------
    -- CASO C: BASE COMPLETA GRIDFINITY CON CUADRÍCULA Y GAP FILLERS (POR DEFECTO)
    ----------------------------------------------------------------------------
    -- Suelo plano continuo para todo el fondo del cajón (Z = 0 a floor_thickness)
    local base_mesh = api.make_cube(d_width, d_depth, floor_thickness)

    -- 1. Marcos y suplementos perimetrales (Gap Fillers)
    if pad_left > 0.5 then
        table.insert(other_volumes, {
            mesh = api.make_cube(pad_left, d_depth, wall_h),
            translate = { x = 0, y = 0, z = floor_thickness }
        })
    end
    if pad_right > 0.5 then
        table.insert(other_volumes, {
            mesh = api.make_cube(pad_right, d_depth, wall_h),
            translate = { x = d_width - pad_right, y = 0, z = floor_thickness }
        })
    end
    if pad_front > 0.5 then
        table.insert(other_volumes, {
            mesh = api.make_cube(grid_w, pad_front, wall_h),
            translate = { x = pad_left, y = 0, z = floor_thickness }
        })
    end
    if pad_back > 0.5 then
        local is_trough = string.find(tostring(gap_treatment), "longitudinal") and (pad_back >= 15.0)
        if is_trough and neg_type then
            local tw = 1.8
            local th = math.max(wall_h, 8.0)
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w, pad_back, th),
                translate = { x = pad_left, y = d_depth - pad_back, z = floor_thickness }
            })
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w - (tw * 2), pad_back - (tw * 2), th),
                type = neg_type,
                translate = { x = pad_left + tw, y = d_depth - pad_back + tw, z = floor_thickness + 1.4 }
            })
        else
            table.insert(other_volumes, {
                mesh = api.make_cube(grid_w, pad_back, wall_h),
                translate = { x = pad_left, y = d_depth - pad_back, z = floor_thickness }
            })
        end
    end

    -- 2. Red de nervaduras divisorias de la cuadrícula Gridfinity
    local rib_w = math.max(2.4, math.min(4.2, PITCH * 0.085))
    -- Nervaduras horizontales
    for row = 0, ny do
        local y_pos = pad_front + (row * PITCH) - (rib_w / 2.0)
        if row == 0 then y_pos = pad_front end
        if row == ny then y_pos = pad_front + grid_d - rib_w end
        table.insert(other_volumes, {
            mesh = api.make_cube(grid_w, rib_w, wall_h),
            translate = { x = pad_left, y = y_pos, z = floor_thickness }
        })
    end
    -- Nervaduras verticales
    for col = 0, nx do
        local x_pos = pad_left + (col * PITCH) - (rib_w / 2.0)
        if col == 0 then x_pos = pad_left end
        if col == nx then x_pos = pad_left + grid_w - rib_w end
        table.insert(other_volumes, {
            mesh = api.make_cube(rib_w, grid_d, wall_h),
            translate = { x = x_pos, y = pad_front, z = floor_thickness }
        })
    end

    -- 3. Celdas Gridfinity: Pestañas en las 4 esquinas de cada celda y orificios de imán
    local corner_tab_size = math.min(8.5, PITCH * 0.22)
    local mag_radius = 3.25
    local mag_depth = math.min(2.4, wall_h)
    local mag_offset = 13.0 * (PITCH / 42.0)

    for col = 1, nx do
        for row = 1, ny do
            local cell_origin_x = pad_left + (col - 1) * PITCH
            local cell_origin_y = pad_front + (row - 1) * PITCH
            local cell_center_x = cell_origin_x + (PITCH / 2.0)
            local cell_center_y = cell_origin_y + (PITCH / 2.0)

            local corners = {
                {x = cell_origin_x, y = cell_origin_y},
                {x = cell_origin_x + PITCH - corner_tab_size, y = cell_origin_y},
                {x = cell_origin_x, y = cell_origin_y + PITCH - corner_tab_size},
                {x = cell_origin_x + PITCH - corner_tab_size, y = cell_origin_y + PITCH - corner_tab_size}
            }
            for _, c in ipairs(corners) do
                table.insert(other_volumes, {
                    mesh = api.make_cube(corner_tab_size, corner_tab_size, wall_h),
                    translate = { x = c.x, y = c.y, z = floor_thickness }
                })
            end

            -- Orificios de imán en las 4 esquinas de la celda
            if magnet_holes and neg_type and base_h >= 3.5 and PITCH >= 30.0 then
                local mag_positions = {
                    {x = cell_center_x - mag_offset, y = cell_center_y - mag_offset},
                    {x = cell_center_x + mag_offset, y = cell_center_y - mag_offset},
                    {x = cell_center_x - mag_offset, y = cell_center_y + mag_offset},
                    {x = cell_center_x + mag_offset, y = cell_center_y + mag_offset}
                }
                for _, mp in ipairs(mag_positions) do
                    table.insert(other_volumes, {
                        mesh = api.make_cylinder(mag_radius, mag_depth),
                        type = neg_type,
                        translate = { x = mp.x, y = mp.y, z = floor_thickness + wall_h - mag_depth }
                    })
                end
            end
        end
    end

    -- 4. Grabado en relieve sobre el borde con las especificaciones
    if emboss_info and api.emboss_text and api.get_default_font then
        pcall(function()
            local label_str = string.format("%dx%d [%.0fmm] - Gap: %.1fx%.1fmm", nx, ny, PITCH, gap_x, gap_y)
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

    -- 5. Añadir el objeto completo a PrusaSlicer
    api.project:add_object {
        mesh = base_mesh,
        other_volumes = other_volumes
    }
end
