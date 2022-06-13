/*resource "aws_networkfirewall_rule_group" "hcp-nia-fw-rg" {
  capacity = 1000
  name     = "hcp-nia-fw-rg"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 2
          rule_definition {
            actions = ["aws:pass"]
           match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 80
                to_port   = 80
              }
              destination {
                address_definition = "54.198.108.158/32"
              }
              destination_port {
                from_port = 80
                to_port   = 80
              }
              protocols = [6]
              tcp_flag {
                flags = ["SYN"]
                masks = ["SYN", "ACK"]
              }
            }
        }
      }
    }
  }
}
}
*/
resource "aws_networkfirewall_rule_group" "hcp-nia-fw-rg-sful" {
  capacity = 1000
  name     = "hcp-nia-fw-rg-sful"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }

}

resource "aws_networkfirewall_rule_group" "hcp-nia-fw-rg-sful-http" {
  capacity = 1000
  name     = "hcp-nia-fw-rg-sful-http"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          destination      = "10.1.10.43/32"
          destination_port = "80"
          direction        = "FORWARD"
          protocol         = "TCP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:2"
        }
      }
    }
  }

}
