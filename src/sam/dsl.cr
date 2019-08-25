module Sam
  # Task definition DSL. Delegates all calls to `Sam` itself.
  module DSL
    def namespace(name : String)
      namespace = Sam.root_namespace.touch_namespace(name)
      with namespace yield
    end

    def desc(description : String)
      Sam.root_namespace.desc(description)
    end

    def task(name, dependencies = [] of String, &block : Task, Args -> Void)
      Sam.root_namespace.task(name, dependencies, &block)
    end

    # Requires tasks from given libraries.
    #
    # ```
    # load_dependencies "library1", "library2"
    # ```
    macro load_dependencies(*libraries, **dependencies)
      {% for l in libraries %}
        require "{{l.id}}/sam"
      {% end %}

      {% for l, deps in dependencies %}
        require "{{l.id}}/sam"

        {% if deps.is_a?(StringLiteral) %}
          {% prefix = deps.starts_with?("/") ? "" : "/tasks/" %}
          require "{{l.id}}{{prefix.id}}{{deps.id}}"
        {% else %}
          {% for dep in deps %}
            {% prefix = dep.starts_with?("/") ? "" : "/tasks/" %}
            require "{{l.id}}{{prefix.id}}{{dep.id}}"
          {% end %}
        {% end %}
      {% end %}
    end
  end
end

include Sam::DSL
