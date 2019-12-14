require 'finance_xl/pry_commands'                                                                                                
require 'pry_commands'
require 'awesome_print'
require 'timecop'

AwesomePrint.pry!

# move its group from FinanceXL to NC so its lumped with other useful custom commands
Pry::Commands['print-accounting'].instance_variable_set :@group, 'NetCredit'

# set colours for displaying accounting entries
colours = FinanceXL::PryCommands::FormatActivities::ACTIVITY_COLOURS

colours['issue']                 = "\e[30;46m"  # black on teal
colours['interest']              = "\e[34;40m"  # blue  on black
colours['payment']               = "\e[30;42m"  # black on green
colours['default']               = "\e[30;45m"  # black on pink
colours['call_due']              = "\e[30;41m"  # black on red
colours['refund']                = "\e[30;46m"  # black on teal
colours['cancel']                = "\e[30;43m"  # black on orange
colours['return']                = "\e[30;43m"  # black on orange
colours['correction']            = "\e[30;47m"  # black on white
colours['waiver']                = "\e[30;46m"  # black on teal
colours['reimburse']             = "\e[30;46m"  # black on teal
colours['charge_off']            = "\e[30;41m"  # black on red
colours['unrecognized_interest'] = "\e[30;40m"  # black on dark
colours['discharge']             = "\e[34;42m"  # blue  on green

def run_accounting_until
  k = 0
  last_loan_id = Loan.last.id

  until yield(k) do
    start_time = Time.now.beginning_of_day

    # 00:00am for daily morning accounting
    Timecop.freeze(start_time)
    Loan.last.perform_daily_accounting!(TimePeriod.morning)

    # 07:30am for statement creation
    Timecop.freeze(start_time + 7.hours + 30.minutes)
    if LoanStatementWorker.scope.include?(last_loan_id)
      LoanStatementWorker.new.perform(last_loan_id, {})
    end

    # 20:00pm for statement creation
    Timecop.freeze(start_time + TimePeriod.evening.hour_start.hours)
    Loan.last.perform_daily_accounting!(TimePeriod.evening)

    # 22:00pm for billing_period_worker
    Timecop.freeze(start_time + 22.hours)
    if BillingPeriodWorker.scope.include?(last_loan_id)
      BillingPeriodWorker.new.perform(last_loan_id)
    end

    # 23:30pm for close_billing_period_worker
    Timecop.freeze(start_time + 23.hours + 30.minutes)
    if CloseBillingPeriodWorker.scope.include?(last_loan_id)
      CloseBillingPeriodWorker.new.perform(last_loan_id)
    end

    Timecop.freeze(Date.tomorrow)
    k += 1
  end
end

def run_accounting_for(time)
  today = Date.today
  run_accounting_until do |k|
    Date.today >= today + time
  end
end

def close_billing_period
  bp = Loan.last.billing_periods.last
  until bp
    run_accounting_for(1.day)
    bp = Loan.last.billing_periods.last
  end

  run_accounting_until do |_|
    Date.today == (bp.end_date + 2)
  end
end

def dev_tennant
  if Tenant.where(tenant: "dev").empty?
    t = Tenant.new
    
    t.tenant      = 'dev'
    t.api_key     = 'dev'
    t.created_at  = Date.parse('2015-10-10')
    t.updated_at  = Date.parse('2015-10-10')
    t.created_by  = 'dev'

    t.save!
  end
end

# Filter all Loans by :netcredit_line_of_credit product
# TODO: Improve this by first selecting the product with :netcredit_line_of_credit, and then passing its ID into the where clause
def nclocs
  Loan.where('product_id': 12)
end

# Shortcuts to get the last of each type in Portfolio
def l
  Loan.last
end

def la
  LoanApplication.last
end

def d
  DrawRequest.last
end

def r
  Rescission.last
end
