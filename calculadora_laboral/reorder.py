import re

with open('lib/presentation/widgets/inputs/liquidation_inputs_panel.dart', 'r', encoding='utf-8') as f:
    code = f.read()

col_start_idx = code.find('children: [')
col_start_idx = code.find('\n', col_start_idx) + 1

fechas_idx = code.find('            // ── Fechas ──')
sueldo_idx = code.find('            // ── Sueldo Bruto ──')
hijos_idx = code.find('            // ── ¿Tiene hijos? ──')
vacaciones_idx = code.find('            // ── ¿Ha gozado vacaciones? ──')
bonos_idx = code.find('            // ── Bonos / Comisiones ──')
horas_idx = code.find('            // ── Horas Extras ──')
pendientes_idx = code.find('            // ── Bonos Pendientes (Liquidación) ──')
caja_gris_idx = code.find('            // ── Caja Gris: Condiciones Laborales ──')
boton_idx = code.find('            // ── Botón Calcular ──')
if boton_idx == -1:
    boton_idx = code.find('            // ✨ Botón Calcular ✨')
end_idx = code.find('          ],\n        ),', boton_idx)

fechas_block = code[fechas_idx:sueldo_idx]
sueldo_block = code[sueldo_idx:hijos_idx]
hijos_block = code[hijos_idx:vacaciones_idx]
vacaciones_block = code[vacaciones_idx:bonos_idx]
bonos_block = code[bonos_idx:horas_idx]
horas_block = code[horas_idx:pendientes_idx]
pendientes_block = code[pendientes_idx:caja_gris_idx]
caja_gris_block = code[caja_gris_idx:boton_idx]
boton_block = code[boton_idx:end_idx]

pre_code = code[:fechas_idx]
post_code = code[end_idx:]

regime_block = '''            // ── Régimen ──
            const Text('Régimen de la Empresa', style: TextStyle(fontSize: 14, color: textDark)),
            const SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CompanyRegime>(
                  value: data.regime,
                  hint: const Text('Seleccionar', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: const [
                    DropdownMenuItem(value: CompanyRegime.general, child: Text('General', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: CompanyRegime.small, child: Text('Pequeña Empresa', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: CompanyRegime.micro, child: Text('Microempresa', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: CompanyRegime.intern, child: Text('Practicante', style: TextStyle(fontSize: 14))),
                  ],
                  onChanged: (val) {
                    if (val != null) notifier.updateRegime(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

'''

new_caja_gris = caja_gris_block
start_del = new_caja_gris.find("const Text('Régimen Laboral'")
end_del = new_caja_gris.find("const SizedBox(height: 12),", start_del) + len("const SizedBox(height: 12),\n")
new_caja_gris = new_caja_gris[:start_del] + new_caja_gris[end_del:]
new_caja_gris = new_caja_gris.replace('Condiciones Laborales', 'Sistema de Pensión y Salud')

new_children = (
    regime_block +
    sueldo_block +
    fechas_block +
    hijos_block +
    bonos_block +
    horas_block +
    new_caja_gris +
    vacaciones_block +
    pendientes_block +
    boton_block
)

new_code = pre_code + new_children + post_code

with open('lib/presentation/widgets/inputs/liquidation_inputs_panel.dart', 'w', encoding='utf-8') as f:
    f.write(new_code)
print('Done!')
