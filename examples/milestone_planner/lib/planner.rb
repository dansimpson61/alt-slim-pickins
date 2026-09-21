# frozen_string_literal: true

module MilestonePlanner
  Task = Struct.new(:id, :title, :owner, :status, :done, keyword_init: true) do
    def done?
      !!done
    end

    def blocked?
      status.to_s == 'blocker'
    end

    def at_risk?
      status.to_s == 'warning'
    end

    def in_progress?
      !done? && status.to_s == 'pending'
    end

    def completed?
      done? || status.to_s == 'ok'
    end

    alias_method :blocked, :blocked?
    alias_method :at_risk, :at_risk?
    alias_method :completed, :completed?

    def badge_variant
      if completed?
        :ok
      elsif blocked?
        :blocker
      elsif at_risk?
        :warning
      else
        :pending
      end
    end

    def status_label
      if completed?
        'Done'
      elsif blocked?
        'Blocked'
      elsif at_risk?
        'At Risk'
      else
        'In Progress'
      end
    end

    def to_h
      super.merge(
        done: done?,
        completed: completed?,
        blocked: blocked?,
        at_risk: at_risk?,
        badge_variant: badge_variant.to_s,
        status_label: status_label
      )
    end
  end

  Milestone = Struct.new(:id, :title, :description, :due_date, :tasks, keyword_init: true) do
    def total_tasks
      tasks.size
    end

    def completed_tasks
      tasks.count(&:completed?)
    end

    def pending_tasks
      tasks.count { |t| !t.completed? }
    end

    def blocked_tasks
      tasks.count(&:blocked?)
    end

    def empty?
      tasks.empty?
    end

    def progress
      return 100 if completed?
      return 0 if empty?

      ((completed_tasks.to_f / total_tasks) * 100).round
    end

    def completed?
      total_tasks.positive? && completed_tasks == total_tasks
    end

    def blocked?
      blocked_tasks.positive?
    end

    def at_risk?
      !completed? && tasks.any?(&:at_risk?)
    end

    alias_method :blocked, :blocked?
    alias_method :at_risk, :at_risk?
    alias_method :completed, :completed?

    def status
      if completed?
        'ok'
      elsif blocked?
        'blocker'
      elsif at_risk?
        'warning'
      else
        'pending'
      end
    end

    def badge_variant
      status.to_sym
    end

    def status_label
      if completed?
        'Complete'
      elsif blocked?
        'Blocked'
      elsif at_risk?
        'At Risk'
      else
        'In Progress'
      end
    end

    def to_h
      super.merge(
        total_tasks: total_tasks,
        completed_tasks: completed_tasks,
        pending_tasks: pending_tasks,
        progress: progress,
        completed: completed?,
        blocked: blocked?,
        at_risk: at_risk?,
        empty: empty?,
        status: status,
        status_label: status_label,
        tasks: tasks.map(&:to_h)
      )
    end
  end

  class Planner
    def self.seed_data
      [
        Milestone.new(
          id: 'm1',
          title: 'Phase 0: Scope the Studio Workbench',
          description: 'Won the studio iteratively into a real development workbench with live rendering.',
          due_date: '2026-09-17',
          tasks: [
            Task.new(id: 't1', title: 'Build palette census of real pages', owner: 'dan', status: 'ok', done: true),
            Task.new(id: 't2', title: 'Live debounced rendering with Stimulus', owner: 'gemini', status: 'ok', done: true),
            Task.new(id: 't3', title: 'Try-it seeds pre-filled from data ledger', owner: 'agent', status: 'ok', done: true),
            Task.new(id: 't4', title: 'Multi-UI trunk and UI picker', owner: 'dan', status: 'ok', done: true)
          ]
        ),
        Milestone.new(
          id: 'm2',
          title: 'Phase 1: The Garden, planted',
          description: 'Plant real demonstration applications exercising different regions of the frozen 64 words.',
          due_date: '2026-09-24',
          tasks: [
            Task.new(id: 't5', title: 'The Lore Reader dynamically parsing LORE.md', owner: 'agent', status: 'ok', done: true),
            Task.new(id: 't6', title: 'The Way Exam testing PRIMER.md rules', owner: 'gemini', status: 'ok', done: true),
            Task.new(id: 't7', title: 'The Milestone Planner with conditional vocabulary', owner: 'gemini', status: 'pending', done: false),
            Task.new(id: 't8', title: 'The Word Graph visualization in the language', owner: 'dan', status: 'pending', done: false)
          ]
        ),
        Milestone.new(
          id: 'm3',
          title: 'Phase 2: Measure the demand',
          description: 'Read-only markdown experiment with dashboard docs and ranking gaps across the garden.',
          due_date: '2026-10-01',
          tasks: [
            Task.new(id: 't9', title: 'Read-only markdown surfaces for dashboard', owner: 'dan', status: 'blocker', done: false),
            Task.new(id: 't10', title: 'Inventory and rank DEMAND.md gaps', owner: 'agent', status: 'pending', done: false)
          ]
        ),
        Milestone.new(
          id: 'm4',
          title: 'Phase 3: Lower the kernel floor',
          description: 'Lower the floor only by demand evidenced by the garden and dashboard.',
          due_date: '2026-10-15',
          tasks: [
            Task.new(id: 't11', title: 'Demand-gated promotion of words from ledger', owner: 'dan', status: 'pending', done: false)
          ]
        ),
        Milestone.new(
          id: 'm5',
          title: 'Phase 4: Future Bluesky Explorations',
          description: 'Open horizon ideas held for future roadmap scoping.',
          due_date: '2026-11-01',
          tasks: []
        )
      ]
    end

    def initialize(milestones = nil)
      @milestones = milestones || self.class.seed_data
    end

    def all
      @milestones
    end

    def find(id)
      @milestones.find { |m| m.id == id.to_s }
    end

    def total_milestones
      @milestones.size
    end

    def completed_milestones
      @milestones.count(&:completed?)
    end

    def total_tasks
      @milestones.sum(&:total_tasks)
    end

    def completed_tasks
      @milestones.sum(&:completed_tasks)
    end

    def overall_progress
      return 0 if total_tasks.zero?

      ((completed_tasks.to_f / total_tasks) * 100).round
    end

    def blocked_tasks_count
      @milestones.sum(&:blocked_tasks)
    end

    def stats
      {
        total_milestones: total_milestones,
        completed_milestones: completed_milestones,
        total_tasks: total_tasks,
        completed_tasks: completed_tasks,
        overall_progress: overall_progress,
        blocked_tasks: blocked_tasks_count
      }
    end

    def add_task(milestone_id, title:, owner:)
      milestone = find(milestone_id) or return nil
      new_id = "t#{total_tasks + 1}"
      task = Task.new(
        id: new_id,
        title: title.to_s.strip,
        owner: owner.to_s.strip,
        status: 'pending',
        done: false
      )
      milestone.tasks << task
      task
    end

    def toggle_task(task_id)
      @milestones.each do |m|
        task = m.tasks.find { |t| t.id == task_id.to_s }
        if task
          task.done = !task.done?
          task.status = task.done? ? 'ok' : 'pending'
          return task
        end
      end
      nil
    end
  end
end
