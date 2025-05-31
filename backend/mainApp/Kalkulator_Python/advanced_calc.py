class AdvancedCalcData:
    def __init__(self,
                fv_system_size_kw: float,
                energy_storage_size_kwh: float,
                consumption_kwh_at_time_func: callable,
                fv_production_kwh_per_panel_at_time_func: callable,
                first_year_energy_buying_price: float,
                first_year_energy_selling_price: float,
                fv_system_installation_cost_per_kw: float,
                yearly_energy_price_increase_percentage: float,
                fv_degradation_percentage_per_year: float,
                energy_storage_degradation_percentage_per_year: float):
        """Initialize the data for the simple calculation."""
        self.first_year_energy_buying_price = first_year_energy_buying_price # PLN / kWh
        self.first_year_energy_selling_price = first_year_energy_selling_price # PLN / kWh
        self.fv_system_installation_cost_per_kw = fv_system_installation_cost_per_kw
        self.fv_system_size_kw = fv_system_size_kw # kW
        self.yearly_energy_price_increase_percentage = yearly_energy_price_increase_percentage / 100.0 # Convert percentage to decimal
        self.energy_storage_size_kwh = energy_storage_size_kwh
        self.fv_degradation_percentage_per_year = fv_degradation_percentage_per_year / 100.0
        self.energy_storage_degradation_percentage_per_year = energy_storage_degradation_percentage_per_year / 100.0
        self.consumption_kwh_at_time_func = consumption_kwh_at_time_func
        self.fv_production_kwh_per_panel_at_time_func = fv_production_kwh_per_panel_at_time_func

    def get_fotovoltaic_system_hourly_production_at(self, efficiency: float, day_of_year: int, hour: int) -> float:
        """Calculate the hourly output of the photovoltaic system based on its size and output percentage."""
        return self.fv_system_size_kw * self.fv_production_kwh_per_panel_at_time_func(self, day_of_year, hour) * max(0, efficiency)

    def get_estimated_hourly_consumption_at(self, day_of_year: int, hour_of_day: int) -> float:
        return self.consumption_kwh_at_time_func(self, day_of_year, hour_of_day)

class AdvancedResultEntry:
    def __init__(self, non_fv_price: float, fv_price: float, es_charge_kwh: float, consumption_kwh: float, production_kwh: float):
        self.non_fv_price = non_fv_price  # PLN
        self.fv_price = fv_price          # PLN
        self.es_charge_kwh = es_charge_kwh  # kWh
        self.consumption_kwh = consumption_kwh  # kWh
        self.production_kwh = production_kwh  # kWh

class AdvancedCalcResult:
    def __init__(self):
        self.upfront_investment_cost = 0.0
        self.results_per_hour: list[AdvancedResultEntry] = []
        self.results_per_year: list[AdvancedResultEntry] = []

    def add_yearly_result(self, year_of_results: list[AdvancedResultEntry]):
        if not year_of_results:
            raise ValueError("Yearly results cannot be empty.")

        non_fv_price = sum(entry.non_fv_price for entry in year_of_results)
        fv_price = sum(entry.fv_price for entry in year_of_results)
        consumption_kwh = sum(entry.consumption_kwh for entry in year_of_results)
        production_kwh = sum(entry.production_kwh for entry in year_of_results)
        es_charge_kwh = sum(entry.es_charge_kwh for entry in year_of_results)

        yearly_result = AdvancedResultEntry(
            non_fv_price=non_fv_price,
            fv_price=fv_price,
            es_charge_kwh=es_charge_kwh,
            consumption_kwh=consumption_kwh,
            production_kwh=production_kwh
        )
        self.results_per_year.append(yearly_result)

    def __str__(self):
        new_str = f"Upfront Investment Cost: {self.upfront_investment_cost} PLN\n" + \
               f"{len(self.results_per_year)} years."
        for i, yearly_result in enumerate(self.results_per_year, start=1):
            new_str += f"\nYear {i}: Without PV: {yearly_result.non_fv_price} PLN, With PV: {yearly_result.fv_price} PLN"

        return new_str

class AdvancedCalc:
    # TODO: Time offset
    def calculate(data: AdvancedCalcData, years: int = 10) -> AdvancedCalcResult:
        if years < 1:
            raise ValueError("Number of years must be at least 1.")

        result = AdvancedCalcResult()
        result.upfront_investment_cost = data.fv_system_installation_cost_per_kw * data.fv_system_size_kw

        current_buying_price = data.first_year_energy_buying_price
        current_selling_price = data.first_year_energy_selling_price

        fv_efficiency = 1.0
        es_capacity_coefficient = 1.0
        es_charge_kwh = 0.0

        for year in range(years):
            year_results = []
            es_capacity = data.energy_storage_size_kwh * es_capacity_coefficient

            for day in range(1, 366):
                for hour in range(24):
                    fv_production = data.get_fotovoltaic_system_hourly_production_at(fv_efficiency, day, hour)
                    consumption = data.get_estimated_hourly_consumption_at(day, hour)

                    balance = fv_production - consumption
                    # Less energy produced than consumed
                    # TODO: Check.
                    # TODO: Add smart algorithm to charge the energy storage.
                    # TODO: Simulate energy storage max charge / discharge rate.
                    if balance < 0:
                        taken_from_storage = min(-balance, es_charge_kwh)
                        es_charge_kwh -= taken_from_storage
                        balance += taken_from_storage
                    else:
                        left_to_charge = min(balance, es_capacity - es_charge_kwh)
                        es_charge_kwh += left_to_charge
                        balance -= left_to_charge

                    energy_sold_kwh = max(0, balance)
                    energy_bought_kwh = max(0, -balance)

                    energy_sold_price = energy_sold_kwh * current_selling_price
                    energy_bought_price = energy_bought_kwh * current_buying_price

                    new_result = AdvancedResultEntry(
                        non_fv_price = consumption * current_buying_price,
                        fv_price = energy_bought_price - energy_sold_price,
                        es_charge_kwh = es_charge_kwh,
                        consumption_kwh = consumption,
                        production_kwh = fv_production,
                    )
                    year_results.append(new_result)
                    result.results_per_hour.append(year_results)

            result.add_yearly_result(year_results)

            # Update prices for the next year
            current_buying_price += (current_buying_price * data.yearly_energy_price_increase_percentage)
            current_selling_price += (current_selling_price * data.yearly_energy_price_increase_percentage)
            # Degradation of the photovoltaic system and energy storage
            fv_efficiency -= (data.fv_degradation_percentage_per_year * fv_efficiency)
            es_capacity_coefficient -= (data.energy_storage_degradation_percentage_per_year * es_capacity_coefficient)

        return result


# TODO: Implement the test functions to simulate the consumption and production of energy at specific times.
def test_get_consumption_kwh_at_time(data: AdvancedCalcData, day_of_year: int, hour_of_day: int) -> float:
    return 1713 / (24 * 365)  # Average hourly consumption based on single_year_energy_consumption

def test_get_production_kwh_at_time(data: AdvancedCalcData, day_of_year: int, hour_of_day: int) -> float:
    diff = hour_of_day - 6
    normalized_hour = (diff / 6.0) - 1  # Normalize to [0, 2] range
    v = 1 - abs(normalized_hour)  # Peak production at noon
    return max(0.0, v)  # Ensure non-negative production

consumption_data = {}
fv_production_data = {}
def data_get_consumption_kwh_at_time(data: AdvancedCalcData, day_of_year: int, hour_of_day: int) -> float:
    return consumption_data[(day_of_year, hour_of_day)]

def data_get_production_kwh_at_time(data: AdvancedCalcData, day_of_year: int, hour_of_day: int) -> float:
    return fv_production_data[(day_of_year, hour_of_day)]

import csv
def load_date_data_from_csv(path):
    ret = {}
    with open(path, 'r') as file:
        reader = csv.reader(file)
        # Skip first row (header)
        next(reader, None)
        for row in reader:
            # Skip empty rows
            if not row or len(row) < 3 or not row[0].isdigit():
                continue

            day_of_year = int(row[0])
            hour_of_day = int(row[1])
            data = float(row[2])
            ret[(day_of_year, hour_of_day)] = data

    return ret

def load_data_from_files():
    consumption_file = "consumption.csv"
    fv_production_file = "fv_production.csv"

    global consumption_data, fv_production_data
    consumption_data = load_date_data_from_csv(consumption_file)
    fv_production_data = load_date_data_from_csv(fv_production_file)


def get_test_data() -> AdvancedCalcData:
    data = AdvancedCalcData(
        fv_system_size_kw = 1.0,
        energy_storage_size_kwh = 10.0,
        consumption_kwh_at_time_func = data_get_consumption_kwh_at_time,
        fv_production_kwh_per_panel_at_time_func = data_get_production_kwh_at_time,

        first_year_energy_buying_price = 1.23,
        first_year_energy_selling_price = 0.5162,
        fv_system_installation_cost_per_kw = 5000.0,
        yearly_energy_price_increase_percentage = 7.1,

        fv_degradation_percentage_per_year = 0.5,
        energy_storage_degradation_percentage_per_year = 2.5
    )

    return data

if __name__ == "__main__":
    print("Loading data from files...")
    load_data_from_files()
    print("Data loaded successfully.")

    data = get_test_data()
    result = AdvancedCalc.calculate(data, years=10)
    print(f"Result:\n{result}")