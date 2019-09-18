defmodule JobBoard.CleanOld do
  alias JobBoard.Jobs
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    clean()
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000) # In 24 hours
  end

  def clean() do
    date = Timex.now
    |> Timex.shift(days: -91)
    for old_jobs <- Jobs.get_jobs_older_than(date) do
      Jobs.delete_job(old_jobs)
    end
  end
end