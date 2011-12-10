require 'twp'

describe TWP::TDL::Parser do
  it 'parses protocols' do
    tdl = TWP::TDL.load <<-TDL
      protocol Echo = ID 2{
        message Request=0{
          string text;
        }

        message Reply=1{
          string text;
          int number_of_letters;
        }
      }
    TDL

    tdl = tdl.elements.first
    tdl.should be_a(TWP::TDL::Protocol)
    tdl.elements.each do |element|
      element.should be_a(TWP::TDL::Message)
      element.fields.each do |field|
        field.should be_a(TWP::TDL::Field)
        field.type.should be_a(TWP::TDL::PrimitiveType)
      end
    end
  end
end
