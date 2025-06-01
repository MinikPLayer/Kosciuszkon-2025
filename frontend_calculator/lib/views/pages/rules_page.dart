import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_calculator/data/notifiers.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});
  @override
  _RulesPageState createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  List<Rule> rules = [
    Rule(
      id: '1',
      name: 'Oszczędzanie energii',
      description: 'Wyłącz ogrzewanie gdy temperatura > 22°C',
      locationId: '1',
      locationName: 'Dom główny',
      deviceId: 'thermo1',
      deviceName: 'Termostat salon',
      isActive: true,
      conditions: [Condition(type: ConditionType.temperature, operator: '>', value: '22', unit: '°C')],
      actions: [Action(type: ActionType.turnOff, targetDeviceId: 'thermo1', targetDeviceName: 'Termostat salon')],
    ),
    Rule(
      id: '2',
      name: 'Bezpieczeństwo nocne',
      description: 'Włącz światła gdy wykryty ruch nocą',
      locationId: '1',
      locationName: 'Dom główny',
      deviceId: 'motion1',
      deviceName: 'Czujnik ruchu',
      isActive: true,
      conditions: [
        Condition(type: ConditionType.motion, operator: '==', value: 'detected', unit: ''),
        Condition(type: ConditionType.time, operator: 'between', value: '22:00-06:00', unit: ''),
      ],
      actions: [
        Action(type: ActionType.turnOn, targetDeviceId: 'light1', targetDeviceName: 'Światło hol', duration: '5m'),
      ],
    ),
    Rule(
      id: '3',
      name: 'Ochrona przed mrozem',
      description: 'Włącz ogrzewanie gdy temperatura < 15°C',
      locationId: '2',
      locationName: 'Domek letniskowy',
      deviceId: 'thermo2',
      deviceName: 'Termostat pokój',
      isActive: false,
      conditions: [Condition(type: ConditionType.temperature, operator: '<', value: '15', unit: '°C')],
      actions: [
        Action(
          type: ActionType.setValue,
          targetDeviceId: 'thermo2',
          targetDeviceName: 'Termostat pokój',
          value: '20',
          unit: '°C',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zarządzanie regułami'),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () => _showAddRuleDialog(context))],
        leading: buildBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text('Reguły automatyzacji', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {
                    // Globalne włączanie/wyłączanie wszystkich reguł
                  },
                ),
                Text('Aktywne'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 16),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                return _buildRuleCard(rules[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(Rule rule) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Switch(
          value: rule.isActive,
          onChanged: (value) {
            setState(() {
              rule.isActive = value;
            });
          },
        ),
        title: Text(rule.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(rule.description),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text('Warunki:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...rule.conditions.map((condition) => _buildConditionItem(condition)).toList(),
                SizedBox(height: 16),
                Text('Akcje:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...rule.actions.map((action) => _buildActionItem(action)).toList(),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => _editRule(rule), child: Text('Edytuj')),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _deleteRule(rule.id),
                      child: Text('Usuń', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(Condition condition) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_getConditionIcon(condition.type), size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text(_formatConditionText(condition), style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionItem(Action action) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_getActionIcon(action.type), size: 20, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(_formatActionText(action), style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  IconData _getConditionIcon(ConditionType type) {
    switch (type) {
      case ConditionType.temperature:
        return Icons.thermostat;
      case ConditionType.time:
        return Icons.access_time;
      case ConditionType.motion:
        return Icons.directions_run;
      case ConditionType.humidity:
        return Icons.water;
      default:
        return Icons.device_unknown;
    }
  }

  IconData _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.turnOn:
        return Icons.power;
      case ActionType.turnOff:
        return Icons.power_off;
      case ActionType.setValue:
        return Icons.settings;
      case ActionType.notify:
        return Icons.notifications;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatConditionText(Condition condition) {
    switch (condition.type) {
      case ConditionType.temperature:
        return 'Temperatura ${condition.operator} ${condition.value}${condition.unit}';
      case ConditionType.time:
        return 'Czas ${condition.operator} ${condition.value}';
      case ConditionType.motion:
        return 'Ruch ${condition.operator} ${condition.value}';
      case ConditionType.humidity:
        return 'Wilgotność ${condition.operator} ${condition.value}${condition.unit}';
      default:
        return '${condition.type}: ${condition.operator} ${condition.value}${condition.unit}';
    }
  }

  String _formatActionText(Action action) {
    switch (action.type) {
      case ActionType.turnOn:
        return 'Włącz ${action.targetDeviceName}${action.duration != null ? ' na ${action.duration}' : ''}';
      case ActionType.turnOff:
        return 'Wyłącz ${action.targetDeviceName}';
      case ActionType.setValue:
        return 'Ustaw ${action.targetDeviceName} na ${action.value}${action.unit}';
      case ActionType.notify:
        return 'Wyślij powiadomienie: ${action.value}';
      default:
        return 'Wykonaj akcję na ${action.targetDeviceName}';
    }
  }

  void _editRule(Rule rule) {
    // Tutaj można dodać logikę edycji reguły
    _showAddRuleDialog(context, rule: rule);
  }

  void _deleteRule(String ruleId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Usunąć regułę?'),
            content: Text('Czy na pewno chcesz usunąć tę regułę?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Anuluj')),
              TextButton(
                onPressed: () {
                  setState(() {
                    rules.removeWhere((rule) => rule.id == ruleId);
                  });
                  Navigator.pop(context);
                },
                child: Text('Usuń', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showAddRuleDialog(BuildContext context, {Rule? rule}) {
    final isEditing = rule != null;
    final nameController = TextEditingController(text: isEditing ? rule.name : '');
    final descController = TextEditingController(text: isEditing ? rule.description : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edytuj regułę' : 'Dodaj nową regułę'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nazwa reguły', border: OutlineInputBorder()),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Opis', border: OutlineInputBorder()),
                ),
                SizedBox(height: 16),
                // Tutaj można dodać bardziej zaawansowany formularz do dodawania warunków i akcji
                Text('Wybierz urządzenie i warunki...'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Anuluj')),
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  // Aktualizuj istniejącą regułę
                  setState(() {
                    rule.name = nameController.text;
                    rule.description = descController.text;
                  });
                } else {
                  // Dodaj nową regułę
                  setState(() {
                    rules.add(
                      Rule(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        description: descController.text,
                        locationId: '1', // Tymczasowo - powinno być wybrane z listy
                        locationName: 'Dom główny',
                        deviceId: 'new-device', // Tymczasowo
                        deviceName: 'Nowe urządzenie',
                        isActive: true,
                        conditions: [],
                        actions: [],
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Zapisz' : 'Dodaj'),
            ),
          ],
        );
      },
    );
  }
}

class Rule {
  String id;
  String name;
  String description;
  String locationId;
  String locationName;
  String deviceId;
  String deviceName;
  bool isActive;
  List<Condition> conditions;
  List<Action> actions;

  Rule({
    required this.id,
    required this.name,
    required this.description,
    required this.locationId,
    required this.locationName,
    required this.deviceId,
    required this.deviceName,
    required this.isActive,
    required this.conditions,
    required this.actions,
  });
}

enum ConditionType { temperature, humidity, motion, time, deviceStatus }

class Condition {
  final ConditionType type;
  final String operator;
  final String value;
  final String unit;

  Condition({required this.type, required this.operator, required this.value, required this.unit});
}

enum ActionType { turnOn, turnOff, setValue, notify }

class Action {
  final ActionType type;
  final String targetDeviceId;
  final String targetDeviceName;
  final String? value;
  final String? unit;
  final String? duration;

  Action({
    required this.type,
    required this.targetDeviceId,
    required this.targetDeviceName,
    this.value,
    this.unit,
    this.duration,
  });
}
