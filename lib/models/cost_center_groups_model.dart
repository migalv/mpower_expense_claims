class CostCentreGroup {
  final String id;
  final String name;

  CostCentreGroup(this.id, this.name);

  CostCentreGroup.fromJson(Map<String, dynamic> json, {String id})
      : this.id = id,
        this.name = json['name'];

  @override
  String toString() {
    return "Cost center: {\n\tid: $id, \n\tname: $name\n}";
  }
}
