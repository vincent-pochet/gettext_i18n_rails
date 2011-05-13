// The GetText main class
function GetTextJson() {

    this.default_locale = 'en'; // The default locale to use
    this.locale         = null; // Can be set by the user
    this.translations   = null; // List of all translations


    this.DOMAIN_SPERATOR = '|';

    // Set the placeholder format. Accepts `{{placeholder}}` and `%{placeholder}`.
    this.PLACE_HOLDER = /(?:\{\{|%\{)(.*?)(?:\}\}?)/gm;

    // Returns the locale currently in use.
    // Returns default_locale if locale is null.
    this.current_locale = function() {
        if (this.locale) {
            return this.locale;
        }
        else {
            return this.default_locale;
        }
    };

    //Get the translation string from list
    this.lookup = function(msgid) {
        if (!msgid) {
            return msgid;
        }

        var locale = this.current_locale();
        var msgstr = msgid;
        if (this.translations[locale] != undefined) {
            if (this.translations[locale][msgid] != undefined) {
                msgstr = this.translations[locale][msgid];
            }
        }
        return msgstr;
    };

    this.is_valid_node = function(obj, node) {
        // local undefined variable in case another library corrupts window.undefined
        var undef;
        return obj[node] !== null && obj[node] !== undef;
    }

    // Merge serveral hash options, checking if value is set before
    // overwriting any value. The precedence is from left to right.
    //
    //   prepare_options({name: "John Doe"}, {name: "Mary Doe", role: "user"});
    //   #=> {name: "John Doe", role: "user"}
    this.prepare_options = function() {
        var options = {};
        var opts;
        var count = arguments.length;

        for (var i = 0; i < count; i++) {
            opts = arguments[i];

            if (!opts) {
                continue;
            }

            for (var key in opts) {
                if (!this.is_valid_node(options, key)) {
                    options[key] = opts[key];
                }
            }
        }
        return options;
    };

    //Replace all option in the message string by values passed in the option list
    this.replace_options = function(msgstr, options) {
        if (!msgstr) {
            return msgstr;
        }

        var message = msgstr;
        options = this.prepare_options(options);

        var matches = message.match(this.PLACE_HOLDER);
        if (!matches) {
            return message;
        }

        var placeholder, value, name;

        for (var i = 0; placeholder = matches[i]; i++) {
            name = placeholder.replace(this.PLACE_HOLDER, "$1");
            if (this.is_valid_node(options, name)) {
                value = options[name];
                regex = new RegExp(placeholder.replace(/\{/gm, "\\{").replace(/\}/gm, "\\}"));
                message = message.replace(regex, value);
            }
        }
        return message;
    };

    // Returns the translation of a string if it exists.
    // Otherwise the string itself is returned.
    this._ = function(msgid, options) {
        if (!msgid) {
            return msgid;
        }

        var msgstr = this.lookup(msgid);
        if (!msgstr)
            msgstr = msgid;

        return this.replace_options(msgstr, options);
    };

    //Pluralize
    this.n_ = function(msgid, msgid_plural, count, options) {

        var msgstr;
        if (count > 1) {
            msgstr = msgid_plural;
        }
        else {
            msgstr = msgid;
        }

        messages = this.lookup(["id:" + msgid + ":plural:" + msgid_plural]);
        if (!messages) {
            return this.replace_options(msgstr, options);
        }

        if (typeof(messages) == "object") {
            if (messages.length && messages.length == 2) {
                if (count > 1) {
                    msgstr = messages[1];
                    if (!msgstr)
                        msgstr = msgid_plural;
                }
                else {
                    msgstr = messages[0];
                    if (!msgstr)
                        msgstr = msgid;
                }
            }
        }
        return this.replace_options(msgstr, options);
    }

    //Scoped translation
    this.s_ = function(msgid, options) { 
        if (!msgid) {
            return msgid;
        }

        var msgstr = this.lookup(msgid);
        if (msgstr == msgid || !msgstr) {
            var splited = msgid.split(this.DOMAIN_SPERATOR);
            msgstr = splited[splited.length-1];
        }
        
        return this.replace_options(msgstr, options);
    }
}

// Creating the GetText instance
var GetText = new GetTextJson();

