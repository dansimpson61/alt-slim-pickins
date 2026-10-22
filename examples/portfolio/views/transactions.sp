ledger, "Activity Ledger"
  actions
    link overview, "← Portfolio overview", to: "/"
  section "Cash flow summary"
    grid metrics, columns: 3
      metric .total_outflow, "Total spending", as: money
      metric .total_inflow, "Total deposits", as: money
      metric .net_cash_flow, "Net cash flow", as: money
  section "Top spending categories"
    table categories
      column category, "Category"
      column total_spend, "Total spend", as: money
      column transaction_count, "Transactions", as: number
  section "Recent activity"
    empty "No transactions recorded yet."
    table transactions
      column date, "Date"
      column account_name, "Account"
      column merchant, "Merchant / Payee"
      column category, "Category"
      column description, "Description"
      column amount, "Amount", as: money
  section "Manage recent transactions"
    empty "No transactions to manage."
    each transaction
      box
        title .merchant
        grid metrics, columns: 3
          metric .date, "Date"
          metric .category, "Category"
          metric .amount, "Amount", as: money
        actions
          link edit, "Edit", to: "/transactions/#{transaction.id}/edit"
          link delete, "Delete", to: "/transactions/#{transaction.id}/delete"
