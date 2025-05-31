class SimpleCalcData:
    def __init__(self,
                single_year_energy_consumption: float,
                first_year_energy_buying_price: float,
                first_year_energy_selling_price: float,
                fv_system_installation_cost_per_kw: float,
                fv_system_size_kw: float,
                fv_system_output_percentage: float,
                autoconsumption_percentage: float,
                yearly_energy_price_increase_percentage: float):
        """Initialize the data for the simple calculation."""
        self.single_year_energy_consumption = single_year_energy_consumption # kWh
        self.first_year_energy_buying_price = first_year_energy_buying_price # PLN / kWh
        self.first_year_energy_selling_price = first_year_energy_selling_price # PLN / kWh
        self.fv_system_installation_cost_per_kw = fv_system_installation_cost_per_kw
        self.fv_system_size_kw = fv_system_size_kw # kW
        self.fv_system_output_percentage = fv_system_output_percentage / 100.0 # Convert percentage to decimal
        self.autoconsumption_percentage = autoconsumption_percentage / 100.0 # Convert percentage to decimal
        self.yearly_energy_price_increase_percentage = yearly_energy_price_increase_percentage / 100.0 # Convert percentage to decimal


    def get_fotovoltaic_system_yearly_output(self) -> float:
        """Calculate the yearly output of the photovoltaic system based on its size and output percentage."""
        return self.fv_system_size_kw * self.fv_system_output_percentage * 24 * 365

    def get_autoconsumption_kw(self) -> float:
        """Calculate the autoconsumption based on the yearly output and autoconsumption percentage."""
        return self.get_fotovoltaic_system_yearly_output() * self.autoconsumption_percentage

class SimpleCalcYearlyResult:
    def __init__(self):
        self.energy_price_without_fotovoltaic = 0.0  # PLN
        self.energy_price_with_fotovoltaic = 0.0     # PLN

class SimpleCalcResult:
    def __init__(self):
        self.upfront_investment_cost = 0.0
        self.energy_prices_per_year: list[SimpleCalcYearlyResult] = []

    def __str__(self):
        new_str = f"Upfront Investment Cost: {self.upfront_investment_cost} PLN\n" + \
               f"{len(self.energy_prices_per_year)} years."
        for i, yearly_result in enumerate(self.energy_prices_per_year, start=1):
            new_str += f"\nYear {i}: Without PV: {yearly_result.energy_price_without_fotovoltaic} PLN, With PV: {yearly_result.energy_price_with_fotovoltaic} PLN"
        return new_str


class SimpleCalc:
    @staticmethod
    def calculate(data: SimpleCalcData, years: int = 10) -> SimpleCalcResult:
        if years < 1:
            raise ValueError("Number of years must be at least 1.")

        result = SimpleCalcResult()
        result.upfront_investment_cost = data.fv_system_installation_cost_per_kw * data.fv_system_size_kw

        current_buying_price = data.first_year_energy_buying_price
        current_selling_price = data.first_year_energy_selling_price

        fv_energy_autoconsumption = data.get_autoconsumption_kw()
        fv_energy_bought = data.single_year_energy_consumption - fv_energy_autoconsumption
        fv_energy_sold = data.get_fotovoltaic_system_yearly_output() - fv_energy_autoconsumption
        for year in range(years):
            yearly_result = SimpleCalcYearlyResult()
            yearly_result.energy_price_without_fotovoltaic = data.single_year_energy_consumption * current_buying_price

            fv_energy_bought_price = fv_energy_bought * current_buying_price
            fv_energy_sold_price = max(0, fv_energy_sold) * current_selling_price

            yearly_result.energy_price_with_fotovoltaic = fv_energy_bought_price - fv_energy_sold_price
            yearly_result.energy_price_without_fotovoltaic = current_buying_price * data.single_year_energy_consumption

            # Update prices for the next year
            current_buying_price += (current_buying_price * data.yearly_energy_price_increase_percentage)
            current_selling_price += (current_selling_price * data.yearly_energy_price_increase_percentage)

            result.energy_prices_per_year.append(yearly_result)

        return result

def get_test_data() -> SimpleCalcData:
    data = SimpleCalcData(
        fv_system_size_kw = 1.0,

        autoconsumption_percentage = 22.0,
        first_year_energy_buying_price = 1.23,
        first_year_energy_selling_price = 0.5162,
        fv_system_installation_cost_per_kw = 5000.0,
        fv_system_output_percentage = 14.2,
        single_year_energy_consumption = 1713.0,
        yearly_energy_price_increase_percentage = 7.1
    )

    return data

if __name__ == "__main__":
    data = get_test_data()
    result = SimpleCalc.calculate(data, years=10)
    print(f"Result:\n{result}")