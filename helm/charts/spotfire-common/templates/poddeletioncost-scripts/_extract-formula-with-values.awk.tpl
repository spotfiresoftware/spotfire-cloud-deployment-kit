# {{- define "spotfire-common.poddeletioncost.script.extract-formula-with-values.awk" -}}
# Pass 1: Extract metric references from formula.
# Supports both:
#   metric_name
#   metric_name{label="value",other="value"}
BEGIN {
    calc = formula

    while (match(calc, /[a-zA-Z_][a-zA-Z0-9_:]*(\{[^}]*\})?/)) {
        outer_start = RSTART
        outer_len = RLENGTH

        before = substr(calc, 1, outer_start - 1)
        token = substr(calc, outer_start, outer_len)

        formula_token_count++
        formula_text_part[formula_token_count] = before
        formula_token_by_index[formula_token_count] = token

        ref_count++
        ref_token_by_index[ref_count] = token

        if (!(token in seen_ref_tokens)) {
            seen_ref_tokens[token] = 1
            unique_ref_tokens[++unique_ref_count] = token

            ref_metric_name[token] = token
            ref_selector_label_count[token] = 0

            if (parse_metric_token(token)) {
                ref_metric_name[token] = parsed_metric_name
                selector = parsed_metric_selector
                parse_label_selector(token, selector)
            }

            # Default to 0 if metric is not found.
            ref_value[token] = 0
        }

        calc = substr(calc, outer_start + outer_len)
    }

    formula_trailing_text = calc
}

# Pass 2: Scrape Prometheus metrics and update the map.
# For labeled formula references, match by metric name + at least one supplied label.
/^[a-zA-Z_][a-zA-Z0-9_:]*/ {
    if (!parse_metric_line($0)) {
        next
    }

    for (i = 1; i <= unique_ref_count; i++) {
        ref = unique_ref_tokens[i]

        if (line_metric_name != ref_metric_name[ref]) {
            continue
        }

        selector_count = ref_selector_label_count[ref]
        if (selector_count == 0) {
            ref_value[ref] = line_value
            continue
        }

        # Requirement: if labels are supplied in formula, matching one supplied label is enough.
        if (line_matches_any_selector_label(ref, line_labels)) {
            ref_value[ref] = line_value
        }
    }
}

# Final pass: substitute placeholders back into formula.
END {
    evaluated_formula = ""

    for (i = 1; i <= formula_token_count; i++) {
        ref = formula_token_by_index[i]
        evaluated_formula = evaluated_formula formula_text_part[i] ref_value[ref]
    }

    evaluated_formula = evaluated_formula formula_trailing_text

    printf evaluated_formula
}

function parse_label_selector(ref, selector,    remaining, pair, key, value) {
    # Normalize escaped quotes that may come from shell argument passing.
    gsub("\\\\\"", "\"", selector)

    remaining = selector

    while (match(remaining, /[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*("[^"]*"|[^,[:space:]}]+)/)) {
        pair_start = RSTART
        pair_len = RLENGTH
        pair = substr(remaining, pair_start, pair_len)

        if (parse_label_pair(pair)) {
            key = parsed_label_key
            value = parsed_label_value

            ref_selector_label_count[ref]++
            idx = ref_selector_label_count[ref]
            ref_selector_label_key[ref, idx] = key
            ref_selector_label_value[ref, idx] = value
        }

        remaining = substr(remaining, pair_start + pair_len)
    }
}

function line_matches_any_selector_label(ref, line_labels,    i, key, value) {
    if (line_labels == "") {
        return 0
    }

    for (i = 1; i <= ref_selector_label_count[ref]; i++) {
        key = ref_selector_label_key[ref, i]
        value = ref_selector_label_value[ref, i]

        if (line_has_label(line_labels, key, value)) {
            return 1
        }
    }

    return 0
}

function line_has_label(line_labels, key, value,    labels_no_braces, escaped_value, pattern) {
    labels_no_braces = line_labels
    sub(/^\{/, "", labels_no_braces)
    sub(/\}$/, "", labels_no_braces)

    escaped_value = escape_regex(value)
    pattern = "(^|,)[[:space:]]*" key "[[:space:]]*=[[:space:]]*\"" escaped_value "\"([[:space:]]*,|$)"

    return (labels_no_braces ~ pattern)
}

function escape_regex(text,    result, i, c) {
    result = ""

    for (i = 1; i <= length(text); i++) {
        c = substr(text, i, 1)
        if (c ~ /[][(){}.+*?^$|\\]/) {
            result = result "\\" c
        } else {
            result = result c
        }
    }

    return result
}

function trim(text,    t) {
    t = text
    sub(/^[[:space:]]+/, "", t)
    sub(/[[:space:]]+$/, "", t)
    return t
}

function parse_metric_token(token,    lb, token_len) {
    token_len = length(token)
    lb = index(token, "{")

    if (lb > 0 && substr(token, token_len, 1) == "}") {
        parsed_metric_name = substr(token, 1, lb - 1)
        parsed_metric_selector = substr(token, lb + 1, token_len - lb - 1)
        return 1
    }

    parsed_metric_name = token
    parsed_metric_selector = ""
    return 0
}

function parse_metric_line(line,    rest, rb) {
    if (!match(line, /^[a-zA-Z_][a-zA-Z0-9_:]*/)) {
        return 0
    }

    line_metric_name = substr(line, RSTART, RLENGTH)
    rest = substr(line, RLENGTH + 1)

    if (substr(rest, 1, 1) == "{") {
        rb = index(rest, "}")
        if (rb == 0) {
            return 0
        }
        line_labels = substr(rest, 1, rb)
        rest = substr(rest, rb + 1)
    } else {
        line_labels = ""
    }

    rest = trim(rest)
    if (rest == "") {
        return 0
    }

    if (!match(rest, /^[^[:space:]]+/)) {
        return 0
    }

    line_value = substr(rest, RSTART, RLENGTH)
    return 1
}

function parse_label_pair(pair,    eq, key, value, value_len) {
    eq = index(pair, "=")
    if (eq == 0) {
        return 0
    }

    key = trim(substr(pair, 1, eq - 1))
    value = trim(substr(pair, eq + 1))
    if (key == "" || value == "") {
        return 0
    }

    if (substr(value, 1, 1) == "\"" && substr(value, length(value), 1) == "\"") {
        value_len = length(value)
        value = substr(value, 2, value_len - 2)
    }

    parsed_label_key = key
    parsed_label_value = value
    return 1
}
# {{- end -}}
