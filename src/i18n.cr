require "./i18n/*"

module I18n
  extend self

  macro define_delegator(name)
    def {{name}}
      config.{{name}}
    end

    def {{name}}=(value)
      config.{{name}} = (value)
    end
  end

  @@inner_config

  # Gets I18n configuration object.
  def config
    @@inner_config ||= I18n::Config.new
  end

  # Sets I18n configuration object.
  def config=(value)
    @@inner_config = value
  end

  def init
    load_path.each do |path|
      config.backend.load(path)
    end
  end

  {% for name in %w(locale backend default_locale available_locales default_separator
                   exception_handler load_path) %}
    define_delegator({{name.id}})
  {% end %}

  def translate(key : String, force_locale = config.locale.to_s, throw = :throw, count = nil, default = nil, iter = nil) : String
    backend = config.backend
    locale = force_locale
    handling = throw

    raise I18n::ArgumentError.new if key.empty?

    result = begin
      backend.translate(locale, key, count: count, default: default)
    rescue e
      e
    end

    # if result.is_a?(MissingTranslation) && handling.is_a?(Proc(MissingTranslation, String, String, NamedTuple))
    #  handling(result, locale, key, options)
    # else
    if result.is_a?(Exception)
      result.inspect
    else
      result
    end
    # end
  end

  def localize(object, force_locale = config.locale.to_s, format = nil, scope = :number)
    backend = config.backend
    locale = force_locale

    result = begin
      backend.localize(locale, object, format: format, scope: scope)
    rescue e
      e
    end

    if result.is_a?(Exception)
      result.inspect
    else
      result
    end
  end
end
